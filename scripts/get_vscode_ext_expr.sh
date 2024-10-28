#!/usr/bin/env nix
#!nix nixpkgs#curl nixpkgs#jq
#!nix --command bash

# Check if required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <publisher> <extension-name>"
    echo "Example: $0 mvllow rose-pine"
    exit 1
fi

PUBLISHER="$1"
EXTENSION_NAME="$2"
EXTENSION_ID="${PUBLISHER}.${EXTENSION_NAME}"

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

# Make the API request and check if it succeeds
if ! curl -s 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
    -H 'accept: application/json;api-version=7.2-preview.1;excludeUrls=true' \
    -H 'content-type: application/json' \
    -H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36' \
    --data-raw "${PAYLOAD}" \
    | jq -r '.results[].extensions[].versions[0].version'; then
    echo "Error: Failed to fetch extension version information"
    exit 1
fi
