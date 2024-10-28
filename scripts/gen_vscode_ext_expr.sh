#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#jq --command bash

print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [EXTENSION]

Generate a Nix expression for a VS Code extension and/or fetch its latest version.

Arguments:
    EXTENSION             Extension reference in format:
                         - publisher.name (e.g., mvllow.rose-pine)
                         - publisher.name@version (e.g., mvllow.rose-pine@2.9.0)

Options:
    -h, --help           Show this help message
    -p, --publisher      Specify publisher (alternative to combined format)
    -n, --name          Specify extension name (alternative to combined format)
    -q, --quiet         Only output the final result (version or nix expression)
    -j, --json          Output full JSON response from marketplace API
    -v, --version-only  Only fetch and output the latest version
    --name-only         Only output the extension name for overlay
    --latest           Auto-fetch latest version (when not specified in reference)

Examples:
    $(basename "$0") mvllow.rose-pine              # Get latest version info
    $(basename "$0") mvllow.rose-pine@2.9.0        # Generate Nix expression
    $(basename "$0") --latest mvllow.rose-pine     # Generate Nix with latest version
    $(basename "$0") -p mvllow -n rose-pine        # Use separate publisher/name
    $(basename "$0") --quiet mvllow.rose-pine      # Only output version/expression
    $(basename "$0") --name-only mvllow.rose-pine  # Only output extension name
EOF
    exit 1
}

# Initialize variables
QUIET=0
JSON=0
VERSION_ONLY=0
NAME_ONLY=0
USE_LATEST=0
PUBLISHER=""
EXTENSION_NAME=""
VERSION=""
EXTENSION_REF=""

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
        -v|--version-only)
            VERSION_ONLY=1
            shift
            ;;
        --name-only)
            NAME_ONLY=1
            shift
            ;;
        --latest)
            USE_LATEST=1
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
            if [[ -z "$EXTENSION_REF" ]]; then
                EXTENSION_REF="$1"
            else
                echo "Error: Unexpected argument '$1'" >&2
                print_usage
            fi
            shift
            ;;
    esac
done

fetch_latest_version() {
    local publisher="$1"
    local name="$2"
    
    # Construct the JSON payload
    local payload="{
        \"assetTypes\": null,
        \"filters\": [{
            \"criteria\": [{
                \"filterType\": 7,
                \"value\": \"${publisher}.${name}\"
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

    # Make the API request
    local response
    response=$(curl -s 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
        -H 'accept: application/json;api-version=7.2-preview.1;excludeUrls=true' \
        -H 'content-type: application/json' \
        -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
        --data-raw "${payload}")

    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch extension information" >&2
        exit 1
    fi

    if [ $JSON -eq 1 ]; then
        echo "$response"
        exit 0
    fi

    echo "$response" | jq -r '.results[].extensions[].versions[0].version'
}

generate_nix_expression() {
    local publisher="$1"
    local name="$2"
    local version="$3"
    
    # Construct the URL
    local url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$name/$version/vspackage"

    # Fetch the SHA256
    local sha256
    if ! sha256=$(nix-prefetch-url "$url" --type sha256 2>/dev/null); then
        echo "Error: Failed to fetch SHA256 hash for $url" >&2
        exit 1
    fi

    # Generate the nix expression
    if [ $QUIET -eq 0 ]; then
        echo "# Generated for $publisher.$name@$version"
    fi

    cat << EOF
$publisher.$name = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    publisher = "$publisher";
    name = "$name";
    version = "$version";
    sha256 = "$sha256";
  };
}
EOF
}

# Process input format and validate
if [[ -n "$EXTENSION_REF" ]]; then
    if [[ "$EXTENSION_REF" == *"@"* ]]; then
        # Format: publisher.name@version
        PUBLISHER="${EXTENSION_REF%%.*}"
        EXTENSION_NAME="${EXTENSION_REF#*.}"
        EXTENSION_NAME="${EXTENSION_NAME%%@*}"
        VERSION="${EXTENSION_REF##*@}"
    else
        # Format: publisher.name
        if [[ "$EXTENSION_REF" != *"."* ]]; then
            echo "Error: Invalid extension format. Use publisher.name or publisher.name@version" >&2
            print_usage
        fi
        PUBLISHER="${EXTENSION_REF%%.*}"
        EXTENSION_NAME="${EXTENSION_REF#*.}"
    fi
elif [[ -z "$PUBLISHER" || -z "$EXTENSION_NAME" ]]; then
    echo "Error: Must provide either publisher.name or both --publisher and --name flags" >&2
    print_usage
fi

# Handle name-only output
if [ $NAME_ONLY -eq 1 ]; then
    echo "${PUBLISHER}-${EXTENSION_NAME}"
    exit 0
fi

# Fetch latest version if needed
if [[ -z "$VERSION" || $USE_LATEST -eq 1 ]]; then
    VERSION=$(fetch_latest_version "$PUBLISHER" "$EXTENSION_NAME")
fi

# Handle version-only output
if [ $VERSION_ONLY -eq 1 ]; then
    echo "$VERSION"
    exit 0
fi

# Generate full expression if not just fetching version
if [ $JSON -eq 0 ]; then
    generate_nix_expression "$PUBLISHER" "$EXTENSION_NAME" "$VERSION"
fi