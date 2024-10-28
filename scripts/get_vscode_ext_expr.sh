#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#jq
#!nix --command bash

print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [EXTENSION]

Fetch the latest version of a VS Code extension.

Arguments:
    EXTENSION             Extension identifier in publisher.name format
                         (e.g., mvllow.rose-pine)

Options:
    -h,  --help          Show this help message
    -p,  --publisher     Specify publisher (alternative to combined format)
    -n,  --name          Specify extension name (alternative to combined format)
    -q,  --quiet        Only output the version number
    -j,  --json         Output full JSON response

Examples:
    $(basename "$0") mvllow.rose-pine
    $(basename "$0") -p mvllow -n rose-pine
    $(basename "$0") --publisher mvllow --name rose-pine
    $(basename "$0") --quiet mvllow.rose-pine
EOF
    exit 1
}

# Initialize variables
QUIET=0
JSON=0
PUBLISHER=""
EXTENSION_NAME=""
EXTENSION_ID=""

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            ;;
        -q|--quiet)
            QUIET=1
            shift
            ;;
        -j|--json)
            JSON=1
            shift
            ;;
        -p|--publisher)
            PUBLISHER="$2"
            shift 2
            ;;
        -n|--name)
            EXTENSION_NAME="$2"
            shift 2
            ;;
        *)
            if [[ -z "$EXTENSION_ID" ]]; then
                EXTENSION_ID="$1"
            else
                echo "Error: Unexpected argument '$1'" >&2
                print_usage
            fi
            shift
            ;;
    esac
done

# Handle input format
if [[ -n "$EXTENSION_ID" ]]; then
    # Validate combined format contains a dot
    if [[ "$EXTENSION_ID" != *"."* ]]; then
        echo "Error: Invalid extension format. Use publisher.extension-name or specify with -p and -n flags" >&2
        print_usage
    fi
    PUBLISHER="${EXTENSION_ID%%.*}"
    EXTENSION_NAME="${EXTENSION_ID#*.}"
elif [[ -n "$PUBLISHER" && -n "$EXTENSION_NAME" ]]; then
    EXTENSION_ID="${PUBLISHER}.${EXTENSION_NAME}"
else
    echo "Error: Must provide either publisher.name or both --publisher and --name flags" >&2
    print_usage
fi

# Construct the JSON payload
PAYLOAD="{
    \"assetTypes\": null,
    \"filters\": [{
        \"criteria\": [{
            \"filterType\": 7,
            \"value\": \"${EXTENSION_ID}\"
        }],
        \"direction\": 2,
        \"pageSize\": 100,
        \"pageNumber\": 1,
        \"sortBy\": 0,
        \"sortOrder\": 0,
        \"pagingToken\": null
    }],
    \"flags\": 2151
}"

# Make the API request with modified output handling
RESPONSE=$(curl -s 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
    -H 'accept: application/json;api-version=7.2-preview.1;excludeUrls=true' \
    -H 'content-type: application/json' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
    --data-raw "${PAYLOAD}")

if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch extension information" >&2
    exit 1
fi

if [ $JSON -eq 1 ]; then
    echo "$RESPONSE" | jq
elif [ $QUIET -eq 1 ]; then
    echo "$RESPONSE" | jq -r '.results[].extensions[].versions[0].version'
else
    VERSION=$(echo "$RESPONSE" | jq -r '.results[].extensions[].versions[0].version')
    echo "${EXTENSION_ID}@${VERSION}"
fi
