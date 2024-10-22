#!/usr/bin/env bash

# Check if an image path was provided
if [ -z "$1" ]; then
    notify-send "Error" "No image path provided"
    exit 1
fi

# Get the image path and directory
image_path="$1"
dir_path=$(dirname "$image_path")
filename=$(basename "$image_path")
timestamp=$(date +%Y%m%d_%H%M%S)

# Create backup
backup_path="${dir_path}/${filename%..*}_backup_${timestamp}.${filename##*.}"
cp "$image_path" "$backup_path"

if [ $? -ne 0 ]; then
    notify-send "Error" "Failed to create backup"
    exit 1
fi

# Create temporary file for upscaled output
temp_output="${dir_path}/${filename%..*}_temp.${filename##*.}"

# Run Real-ESRGAN upscaling
realesrgan-ncnn-vulkan -i "$image_path" -o "$temp_output" -n realesrgan-x4plus -s 4

if [ $? -ne 0 ]; then
    notify-send "Error" "Upscaling failed"
    rm -f "$temp_output"
    exit 1
fi

# Replace original with upscaled version
mv "$temp_output" "$image_path"

if [ $? -ne 0 ]; then
    notify-send "Error" "Failed to replace original file"
    rm -f "$temp_output"
    exit 1
fi

notify-send "Success" "Image upscaled and backup created"