#!/usr/bin/env nix
#!nix shell nixpkgs#jsbeautifier nixpkgs#jq --command bash

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

# Find JS files mentioned in another JS file
find_js_dependencies() {
    local file="$1"
    local base_dir
    base_dir=$(dirname "$file")

    # Use grep to find potential JS dependencies
    {
        # Look for import statements
        grep -o "import.*from '[^']*\.js'" "$file" 2>/dev/null | sed "s/.*from '\([^']*\)'.*/\1/" || true
        grep -o 'import.*from "[^"]*\.js"' "$file" 2>/dev/null | sed 's/.*from "\([^"]*\)".*/\1/' || true

        # Look for require statements
        grep -o "require('[^']*\.js')" "$file" 2>/dev/null | sed "s/require('\([^']*\)').*/\1/" || true
        grep -o 'require("[^"]*\.js")' "$file" 2>/dev/null | sed 's/require("\([^"]*\)".*/\1/' || true

        # Look for loadScript calls
        grep -o "loadScript('[^']*\.js')" "$file" 2>/dev/null | sed "s/loadScript('\([^']*\)').*/\1/" || true
        grep -o 'loadScript("[^"]*\.js")' "$file" 2>/dev/null | sed 's/loadScript("\([^"]*\)".*/\1/' || true

        # Look for src attributes
        grep -o "src='[^']*\.js'" "$file" 2>/dev/null | sed "s/src='\([^']*\)'.*/\1/" || true
        grep -o 'src="[^"]*\.js"' "$file" 2>/dev/null | sed 's/src="\([^"]*\)".*/\1/' || true
    } | while read -r dep; do
        # Handle relative paths
        if [[ $dep == ./* ]] || [[ $dep == ../* ]]; then
            (cd "$base_dir" && realpath "$dep")
        else
            # Try to find the file relative to the current directory
            local possible_path="$base_dir/$dep"
            if [ -f "$possible_path" ]; then
                realpath "$possible_path"
            fi
        fi
    done
}

# Get all JS files from manifest
get_manifest_js_files() {
    local manifest="$1"
    local base_dir
    base_dir=$(dirname "$manifest")

    {
        # Background scripts
        jq -r '.background.scripts[]? // empty' "$manifest" 2>/dev/null || true

        # Content scripts
        jq -r '.content_scripts[]?.js[]? // empty' "$manifest" 2>/dev/null || true

        # Web accessible resources (handle both v2 and v3)
        jq -r '
            if (.web_accessible_resources | type) == "array" then
                .web_accessible_resources[]? | select(endswith(".js"))
            elif (.web_accessible_resources | type) == "object" then
                .web_accessible_resources[]?.resources[]? | select(endswith(".js"))
            else
                empty
            end
        ' "$manifest" 2>/dev/null || true
    } | while read -r js_file; do
        realpath "$base_dir/$js_file"
    done
}

# Process a JS file and output it in the required format
process_js_file() {
    local file="$1"
    local rel_path
    rel_path=${file#"$HOME/"}

    echo "--- BEGIN $rel_path ---"
    js-beautify -l2 "$file" 2>/dev/null || cat "$file"
    echo "--- END $rel_path ---"
    echo
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

    # Process manifest
    echo "--- BEGIN ${manifest#"$HOME/"} ---"
    jq '.' "$manifest"
    echo "--- END ${manifest#"$HOME/"} ---"
    echo

    # Create temporary files
    local files_to_process
    local new_files
    files_to_process=$(mktemp)
    new_files=$(mktemp)
    trap 'rm -f "$files_to_process" "$new_files"' EXIT

    # Get initial JS files from manifest
    get_manifest_js_files "$manifest" | sort -u >"$files_to_process"

    # Process JS files and their dependencies
    local processed_files=""
    while true; do
        # Clear the new files list
        : >"$new_files"

        # Process current batch of files
        while IFS= read -r js_file; do
            # Skip if already processed
            if [[ $processed_files == *"$js_file"* ]]; then
                continue
            fi

            # Process the file
            if [ -f "$js_file" ]; then
                process_js_file "$js_file"
                processed_files="$processed_files:$js_file"

                # Find dependencies and add them to the new files list
                find_js_dependencies "$js_file" | sort -u >>"$new_files"
            fi
        done <"$files_to_process"

        # If no new files were found, we're done
        if [ ! -s "$new_files" ]; then
            break
        fi

        # Update files to process for next iteration
        cp "$new_files" "$files_to_process"
    done
}

main "$@"
