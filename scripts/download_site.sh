#!/usr/bin/env nix
#!nix shell nixpkgs#parallel nixpkgs#curl nixpkgs#pup nixpkgs#aichat
#!nix --command bash

set -euo pipefail

# Check if URL argument is provided
if [ $# -ne 1 ]; then
	echo "Usage: $0 <url>"
	exit 1
fi

url=$1
base_url=$(echo "$url" | sed -E 's|^(https?://[^/]+).*|\1|')
prompt="Turn this html into beautiful markdown as best makes sense."

# Create a temp directory for output
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

curl -sL "$url" |
	pup 'a attr{href}' |
	rg '^/[^/]+' |
	sort -u | # Remove duplicates
	parallel \
		--progress \
		--jobs 4 \
		--keep-order \
		--joblog "$tmp_dir/parallel.log" \
		"curl -sL '${base_url}{}' | aichat --no-stream \"$prompt\" > \"$tmp_dir/{#}.md\""

# Combine all markdown files
cat "$tmp_dir"/*.md >combined_output.md

echo "Conversion complete. Output saved to combined_output.md"
