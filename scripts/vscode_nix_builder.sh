#!/usr/bin/env nix
#!nix shell nixpkgs#curl --command bash

print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <EXTENSION_REF>

Generate a Nix expression for a VS Code extension.

Arguments:
    EXTENSION_REF        Extension reference in format: publisher.name@version
                        (e.g., mvllow.rose-pine@2.9.0)

Options:
    -h, --help          Show this help message
    -q, --quiet         Only output the Nix expression
    -n, --name-only     Only output the extension name for overlay

Examples:
    $(basename "$0") mvllow.rose-pine@2.9.0
    $(basename "$0") --quiet kenhowardpdx.vscode-gist@3.0.3
EOF
    exit 1
}

# Initialize variables
QUIET=0
NAME_ONLY=0

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
        -n|--name-only)
            NAME_ONLY=1
            shift
            ;;
        *)
            EXTENSION_REF="$1"
            shift
            ;;
    esac
done

# Validate extension reference format
if [[ ! "$EXTENSION_REF" =~ ^[^.]+\.[^@]+@.+$ ]]; then
    echo "Error: Invalid extension reference format. Expected: publisher.name@version" >&2
    print_usage
fi

# Parse the extension reference
PUBLISHER="${EXTENSION_REF%%.*}"
NAME="${EXTENSION_REF#*.}"
NAME="${NAME%%@*}"
VERSION="${EXTENSION_REF##*@}"

# Construct the URL
URL="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$PUBLISHER/vsextensions/$NAME/$VERSION/vspackage"

if [ $NAME_ONLY -eq 1 ]; then
    echo "${PUBLISHER}-${NAME}"
    exit 0
fi

# Fetch the SHA256 using nix-prefetch-url
if ! SHA256=$(nix-prefetch-url "$URL" --type sha256 2>/dev/null); then
    echo "Error: Failed to fetch SHA256 hash for $URL" >&2
    exit 1
fi

# Generate the final nix expression
if [ $QUIET -eq 0 ]; then
    echo "# Generated for $EXTENSION_REF"
fi

cat << EOF
$PUBLISHER.$NAME = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    publisher = "$PUBLISHER";
    name = "$NAME";
    version = "$VERSION";
    sha256 = "$SHA256";
  };
}
EOF
