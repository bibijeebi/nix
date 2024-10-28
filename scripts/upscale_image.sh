#!/usr/bin/env nix
#!nix shell nixpkgs#realesrgan-ncnn-vulkan nixpkgs#notify-send
#!nix --command bash

set -euo pipefail

# Validate input
if [ $# -ne 1 ]; then
	notify-send "Error" "Usage: $0 <image_path>"
	exit 1
fi

# Initialize variables
image_path="$1"
filename=$(basename "$image_path")
extension="${filename##*.}"
name="${filename%.*}"
timestamp=$(date +%Y%m%d_%H%M%S)
backup_path="/tmp/upscale_backup"

# Create backup
mkdir -p "$backup_path"
cp "$image_path" "$backup_path/${name}_${timestamp}.${extension}"

# Upscale image
realesrgan-ncnn-vulkan \
	-i "$image_path" \
	-o "$image_path" \
	-n realesrgan-x4plus

notify-send "Success" "Image upscaled and backup created"
