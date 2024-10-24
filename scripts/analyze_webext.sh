#!/usr/bin/env nix
#!nix shell nixpkgs#jsbeautifier nixpkgs#jq nixpkgs#curl --command bash

set -euo pipefail

# Find the latest version directory for an extension
find_extension_path() {
    local ext_id="$1"
    local chrome_dir="$HOME/.config/google-chrome/Default/Extensions"
    local ext_path="$chrome_dir/$ext_id"

    if [ ! -d "$ext_path" ]; then
        echo "Error: Extension $ext_id not found" >&2
        exit 1
    fi

    local latest_version
    latest_version=$(find "$ext_path" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -V | tail -n1)
    echo "$ext_path/$latest_version"
}

# Check if a JS file is likely to contain core functionality
is_core_functionality() {
    local file="$1"
    local filename
    local dirpath
    filename=$(basename "$file")
    dirpath=$(dirname "$file")

    # Skip obvious library files
    if [[ $filename == jquery* ]] ||
        [[ $filename == angular* ]] ||
        [[ $filename == react* ]] ||
        [[ $filename == vue* ]] ||
        [[ $filename == lodash* ]] ||
        [[ $filename == polyfill* ]]; then
        return 1
    fi

    # Prioritize key extension components
    if [[ $filename == background.js ]] ||
        [[ $filename == content.js ]] ||
        [[ $filename == index.js ]] ||
        [[ $filename == popup.js ]] ||
        [[ $filename == options.js ]] ||
        [[ $filename == main.js ]] ||
        [[ $dirpath == */js/* ]] ||
        [[ $dirpath == */src/* ]] ||
        [[ $dirpath == */background/* ]] ||
        [[ $dirpath == */content/* ]]; then
        return 0
    fi

    # Check for potentially obfuscated code
    if grep -q -E '(eval\(|Function\(|base64|fromCharCode|unescape\()' "$file"; then
        return 0
    fi

    # Include files with suspicious patterns
    if grep -q -E '([a-zA-Z0-9]{30,}|[_$]{2,}|\\x[0-9a-f]{2})' "$file"; then
        return 0
    fi

    return 1
}

# Format the output with highlighting
format_analysis() {
    local analysis="$1"

    # Extract and highlight key functionality
    echo -e "\033[1;36m=== CORE FUNCTIONALITY ===\033[0m"
    echo "$analysis" | awk '/^## Core Features/,/^## Implementation Details/' | grep -v "^## Implementation Details"
    echo

    # Output deobfuscated code sections
    echo -e "\033[1;32m=== DEOBFUSCATED CODE ===\033[0m"
    echo "$analysis" | awk '/^## Deobfuscated Sections/,/^## Dependencies/' | grep -v "^## Dependencies"
    echo

    # Output full analysis
    echo -e "\033[1;34m=== FULL ANALYSIS ===\033[0m"
    echo "$analysis"
}

# Call Anthropic API to analyze the extension
analyze_extension() {
    local content
    content=$(cat)
    local api_key="$ANTHROPIC_API_KEY"

    if [ -z "$api_key" ]; then
        echo "Error: ANTHROPIC_API_KEY environment variable not set" >&2
        exit 1
    fi

    local prompt='As a Chrome extension reverse engineer, analyze this extension code focusing on understanding its functionality and implementation details. Pay special attention to obfuscated code and try to explain its purpose.

Here is the extension code:

<extension_code>
'"$content"'
</extension_code>

# 1. OVERVIEW (50 words)
Core purpose and key technical components.

# 2. FUNCTIONALITY ANALYSIS

## Core Features
For each feature:
- Purpose
- Implementation location [file:line]
- How it works
- API endpoints used (if any)
- Notable implementation details

## Implementation Details
For each component:
- Component purpose
- Key functions and their roles
- Data flow
- Interesting techniques used
- Browser APIs leveraged

## Deobfuscated Sections
For each obfuscated section:
- Location: [file:line]
- Original code snippet
- Deobfuscated version
- Explanation of functionality
- Implementation notes
Maximum 5 sections, focusing on most interesting parts

## Dependencies
- Required permissions
- External services used
- Notable libraries
Maximum 3 bullets

# 3. IMPLEMENTATION GUIDE

## Key Components to Reimplement
For each component:
- Functionality description
- Required permissions
- Implementation approach
- Code example
- Testing considerations

## Integration Points
- Content script injection
- Background worker setup
- Message passing
- Storage usage
Maximum 3 bullets per section

Focus on novel or interesting functionality that could be reused in other extensions.
Include specific code examples for the most interesting features.'

    # Create a temporary file for the JSON payload
    local tmp_json
    tmp_json=$(mktemp)
    trap 'rm -f "$tmp_json"' EXIT

    # Write the JSON payload to the temporary file
    cat >"$tmp_json" <<EOF
{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 4000,
    "temperature": 0,
    "messages": [
        {
            "role": "user",
            "content": $(printf '%s' "$prompt" | jq -R -s '.')
        }
    ]
}
EOF

    # Make the API call
    local response
    response=$(curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $api_key" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d @"$tmp_json")

    # Extract and format the content
    local analysis
    analysis=$(echo "$response" | jq -r '.content[0].text')
    format_analysis "$analysis"

    # Print the original prompt
    echo -e "\n\033[1;35m=== ORIGINAL PROMPT ===\033[0m"
    echo "$prompt"
}

# Get relevant JS files from manifest
get_manifest_js_files() {
    local manifest="$1"
    local base_dir
    base_dir=$(dirname "$manifest")

    {
        # Background scripts/worker
        jq -r '.background.scripts[]? // empty' "$manifest" 2>/dev/null || true
        jq -r '.background.service_worker? // empty' "$manifest" 2>/dev/null || true

        # Content scripts
        jq -r '.content_scripts[]?.js[]? // empty' "$manifest" 2>/dev/null || true
    } | while read -r file; do
        if [[ $file == *.js ]]; then
            local full_path
            full_path="$(realpath "$base_dir/$file")"
            if is_core_functionality "$full_path"; then
                echo "$full_path"
            fi
        fi
    done
}

# Main script
main() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <extension_id>" >&2
        exit 1
    fi

    local ext_id="$1"
    local ext_path
    ext_path=$(find_extension_path "$ext_id")
    local manifest="$ext_path/manifest.json"

    # Collect and analyze the extension content
    {
        # Process manifest
        echo "--- BEGIN manifest.json ---"
        jq '.' "$manifest"
        echo "--- END manifest.json ---"
        echo

        # Process JS files specified in manifest
        while IFS= read -r js_file; do
            if [ -f "$js_file" ]; then
                local rel_path="${js_file#"$HOME/"}"
                echo "--- BEGIN $rel_path ---"
                js-beautify -l2 "$js_file" 2>/dev/null || cat "$js_file"
                echo "--- END $rel_path ---"
                echo
            fi
        done < <(get_manifest_js_files "$manifest")

        # Look for other interesting JS files
        while IFS= read -r file; do
            if is_core_functionality "$file"; then
                local rel_path="${file#"$HOME/"}"
                echo "--- BEGIN $rel_path ---"
                js-beautify -l2 "$file" 2>/dev/null || cat "$file"
                echo "--- END $rel_path ---"
                echo
            fi
        done < <(find "$ext_path" -type f -name "*.js")
    } | analyze_extension
}

main "$@"
