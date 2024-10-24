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

    # Get the latest version directory
    local latest_version
    latest_version=$(find "$ext_path" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -V | tail -n1)
    echo "$ext_path/$latest_version"
}

# Check if a JS file is likely worth analyzing
is_interesting_js() {
    local file="$1"
    local filename
    local dirpath
    filename=$(basename "$file")
    dirpath=$(dirname "$file")

    # Skip minified files
    if [[ $filename == *.min.js ]] || [[ $filename == *-min.js ]]; then
        return 1
    fi

    # Skip common library files
    if [[ $filename == jquery* ]] ||
        [[ $filename == angular* ]] ||
        [[ $filename == react* ]] ||
        [[ $filename == vue* ]] ||
        [[ $filename == lodash* ]] ||
        [[ $filename == polyfill* ]]; then
        return 1
    fi

    # Skip files in common library directories
    if [[ $dirpath == */vendor/* ]] ||
        [[ $dirpath == */lib/* ]] ||
        [[ $dirpath == */dist/* ]] ||
        [[ $dirpath == */build/* ]] ||
        [[ $dirpath == */node_modules/* ]]; then
        return 1
    fi

    # Prioritize common extension source files
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

    # If it's a lone JS file in the extension root or a small directory
    local js_count
    js_count=$(find "$(dirname "$file")" -maxdepth 1 -name "*.js" | wc -l)
    if [ "$js_count" -le 2 ]; then
        return 0
    fi

    # Check file size - skip very large files (likely bundled/generated)
    local file_size
    file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    if [ "$file_size" -gt 500000 ]; then # Skip files larger than 500KB
        return 1
    fi

    return 1
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

    local prompt
    prompt=$(
        cat <<EOF
Here is the Chrome extension code to analyze:

<extension_code>
$content
</extension_code>

You are an expert in Chrome extension development and code analysis. Your task is to analyze the provided Chrome extension code, focusing on identifying novel functionality, understanding implementation details, and potentially de-obfuscating code sections. The goal is to provide insights that could be useful for reimplementing interesting features in other extensions.

Please provide a comprehensive analysis of this code, following these steps:

1. Novel Functionality Analysis
    - List potential unique or interesting features in the extension
    - For each potential feature:
        - Describe how it works
        - Explain why it might be valuable or innovative
        - Rate its novelty on a scale of 1-5

2. Key Components Analysis
    - Create a tree structure of the main components or modules of the extension
    - For each component:
        - Describe its purpose
        - Explain how it's implemented
        - Highlight any notable coding techniques or patterns used

3. Obfuscation Analysis (if applicable)
    - List potential obfuscation techniques you observe in the code
    - For each technique:
        - Describe how it's implemented
        - Attempt to de-obfuscate a small section
        - Explain the underlying functionality of the de-obfuscated section
        - Provide a clean, readable version of the de-obfuscated code snippet

4. Summary
    - Provide an overview of the extension's core functionality
    - Highlight the most interesting or reusable code sections
    - Suggest potential ways to adapt or improve upon the extension's features

Before providing your final analysis, wrap your analysis inside <code_breakdown> tags to break down your findings and show your thought process. This will help ensure a thorough interpretation of the code.

In your analysis and final output, prioritize:
1. Understanding and explaining novel functionality
2. Identifying interesting implementation techniques
3. De-obfuscating complex code sections
4. Providing insights for potential reuse or adaptation of code

Please proceed with your analysis of the Chrome extension code.
EOF
    )

    echo "--- BEGIN ANALYSIS ---"
    curl -s "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $api_key" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d "$(
            cat <<EOF
{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 8192,
    "temperature": 0,
    "messages": [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": $(jq -R -s '.' <<<"$prompt")
                }
            ]
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "text",
                    "text": "<code_breakdown>"
                }
            ]
        }
    ]
}
EOF
        )" | jq -r '.content[0].text'
    echo "--- END ANALYSIS ---"
    echo
    echo "--- BEGIN CONTENT ---"
    echo "$content"
    echo "--- END CONTENT ---"
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
            if is_interesting_js "$full_path"; then
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

        # Look for other interesting JS files in common locations
        while IFS= read -r file; do
            if is_interesting_js "$file"; then
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
