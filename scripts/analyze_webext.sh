#!/usr/bin/env nix
#!nix shell nixpkgs#jsbeautifier nixpkgs#jq nixpkgs#curl
#!nix --command bash

set -euo pipefail

# Configuration
readonly DEFAULT_MAX_FILE_SIZE=500000 # 500KB
readonly ANTHROPIC_MODEL="claude-3-5-sonnet-20241022"
readonly CHROME_EXTENSION_DIR="$HOME/.config/google-chrome/Default/Extensions"

# Common library files to skip
readonly SKIP_LIBRARIES=(
    "jquery" "angular" "react" "vue" "lodash" "polyfill"
)

# Common library directories to skip
readonly SKIP_DIRECTORIES=(
    "vendor" "lib" "dist" "build" "node_modules"
)

# Priority extension source files
readonly PRIORITY_FILES=(
    "background.js" "content.js" "index.js" "popup.js"
    "options.js" "main.js"
)

# Priority directories
readonly PRIORITY_DIRS=(
    "js" "src" "background" "content"
)

# Colors for output
readonly COLOR_ERROR='\033[0;31m'
readonly COLOR_SUCCESS='\033[0;32m'
readonly COLOR_WARNING='\033[1;33m'
readonly COLOR_NC='\033[0m'

# Logging functions
log_error() {
    echo -e "${COLOR_ERROR}Error: $1${COLOR_NC}" >&2
}

log_success() {
    echo -e "${COLOR_SUCCESS}$1${COLOR_NC}"
}

log_warning() {
    echo -e "${COLOR_WARNING}Warning: $1${COLOR_NC}"
}

# Find the latest version directory for an extension
find_extension_path() {
    local ext_id="$1"
    local ext_path="$CHROME_EXTENSION_DIR/$ext_id"

    if [ ! -d "$ext_path" ]; then
        log_error "Extension $ext_id not found"
        exit 1
    fi

    # Get the latest version directory
    local latest_version
    latest_version=$(find "$ext_path" -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -V | tail -n1)
    echo "$ext_path/$latest_version"
}

# Check if a JS file is worth analyzing
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
    for lib in "${SKIP_LIBRARIES[@]}"; do
        if [[ $filename == $lib* ]]; then
            return 1
        fi
    done

    # Skip files in common library directories
    for dir in "${SKIP_DIRECTORIES[@]}"; do
        if [[ $dirpath == */$dir/* ]]; then
            return 1
        fi
    done

    # Prioritize common extension source files
    for priority_file in "${PRIORITY_FILES[@]}"; do
        if [[ $filename == "$priority_file" ]]; then
            return 0
        fi
    done

    for priority_dir in "${PRIORITY_DIRS[@]}"; do
        if [[ $dirpath == */$priority_dir/* ]]; then
            return 0
        fi
    done

    # If it's a lone JS file in the extension root or a small directory
    local js_count
    js_count=$(find "$(dirname "$file")" -maxdepth 1 -name "*.js" | wc -l)
    if [ "$js_count" -le 2 ]; then
        return 0
    fi

    # Check file size - skip very large files (likely bundled/generated)
    local file_size
    file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    if [ "$file_size" -gt "$DEFAULT_MAX_FILE_SIZE" ]; then
        return 1
    fi

    return 1
}

# Analyze extension using Anthropic API
analyze_extension() {
    local content
    content=$(cat)
    local api_key="$ANTHROPIC_API_KEY"

    if [ -z "$api_key" ]; then
        log_error "ANTHROPIC_API_KEY environment variable not set"
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

Before providing your final analysis, wrap your analysis inside <code_breakdown> tags to break down your findings and show your thought process.
EOF
    )

    # Call Anthropic API with retry mechanism
    local max_retries=3
    local retry_count=0
    local response

    echo "--- BEGIN ANALYSIS ---"

    while [ $retry_count -lt $max_retries ]; do
        response=$(curl -s "https://api.anthropic.com/v1/messages" \
            -H "x-api-key: $api_key" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -d "$(
                jq -n \
                    --arg model "$ANTHROPIC_MODEL" \
                    --arg prompt "$prompt" \
                    '{
                        "model": $model,
                        "max_tokens": 8192,
                        "temperature": 0,
                        "messages": [
                            {
                                "role": "user",
                                "content": [
                                    {
                                        "type": "text",
                                        "text": $prompt
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
                    }'
            )" 2>/dev/null)

        if [ -n "$response" ] && echo "$response" | jq -r '.content[0].text'; then
            break
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                log_warning "API call failed, retrying in 5 seconds..."
                sleep 5
            else
                log_error "Failed to call Anthropic API after $max_retries attempts"
                exit 1
            fi
        fi
    done

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

# Main script execution
main() {
    if [ $# -ne 1 ]; then
        log_error "Usage: $0 <extension_id>"
        exit 1
    fi

    local ext_id="$1"
    local ext_path
    ext_path=$(find_extension_path "$ext_id")
    local manifest="$ext_path/manifest.json"

    log_success "Analyzing extension: $ext_id"
    log_success "Path: $ext_path"

    # Process and analyze the extension content
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
