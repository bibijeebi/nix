#!/usr/bin/env nix
#!nix shell --impure --file deps.nix
#!nix --command python

import sys
import os
import cv2
import mediapipe as mp
import numpy as np
import argparse
import glob
from datetime import datetime
import shutil

# Configuration - Default parameters
DEFAULT_CONFIG = {
    'MIN_PADDING_PERCENT': 8,
    'MAX_PADDING_PERCENT': 25,
    'MIN_PADDING_PIXELS': 30,
    'MAX_ASPECT_RATIO': 1.5,
    'MIN_ASPECT_RATIO': 0.5,
    'MIN_LANDMARK_VISIBILITY': 0.5,
    'MODEL_COMPLEXITY': 1,
    'SAVE_DEBUG_IMAGES': False,
}

def check_dependencies():
    try:
        import cv2
        import mediapipe
    except ImportError:
        print("Error: Required Python packages not found.")
        print("Please install them using:")
        print("nix-shell -p python3 python3Packages.opencv4 python3Packages.mediapipe")
        sys.exit(1)

def calculate_padding(bbox, img_shape, config):
    """Calculate padding with configurable parameters."""
    x1, y1, x2, y2 = bbox
    img_height, img_width = img_shape[:2]
    
    # Calculate person dimensions
    person_width, person_height = x2 - x1, y2 - y1
    
    # Calculate dynamic padding based on person size
    person_size_ratio = (person_width * person_height) / (img_width * img_height)
    dynamic_pad_percent = max(
        config['MIN_PADDING_PERCENT'],
        min(config['MAX_PADDING_PERCENT'],
            int(config['MIN_PADDING_PERCENT'] * (1 + (1 - person_size_ratio) * 2)))
    )
    
    # Calculate padding in pixels
    pad_x = max(int(person_width * dynamic_pad_percent / 100), 
                config['MIN_PADDING_PIXELS'])
    pad_y = max(int(person_height * dynamic_pad_percent / 100), 
                config['MIN_PADDING_PIXELS'])
    
    # Add padding while keeping within image boundaries
    x1_pad = max(0, x1 - pad_x)
    y1_pad = max(0, y1 - pad_y)
    x2_pad = min(img_width, x2 + pad_x)
    y2_pad = min(img_height, y2 + pad_y)
    
    # Adjust aspect ratio if needed
    width = x2_pad - x1_pad
    height = y2_pad - y1_pad
    aspect_ratio = width / height
    
    if aspect_ratio > config['MAX_ASPECT_RATIO']:
        target_width = int(height * config['MAX_ASPECT_RATIO'])
        diff = width - target_width
        x1_pad += diff // 2
        x2_pad -= diff // 2
    elif aspect_ratio < config['MIN_ASPECT_RATIO']:
        target_height = int(width / config['MIN_ASPECT_RATIO'])
        diff = height - target_height
        y1_pad += diff // 2
        y2_pad -= diff // 2
    
    return [x1_pad, y1_pad, x2_pad, y2_pad]

def make_backup(file_path, backup_pattern=None):
    """Create a backup of the file using the specified pattern."""
    if backup_pattern is None:
        # Default backup pattern: filename.ext.YYYY-MM-DD_HHMMSS.bak
        timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        backup_path = f"{file_path}.{timestamp}.bak"
    else:
        # Replace patterns in backup_pattern
        timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        dirname = os.path.dirname(file_path)
        basename = os.path.basename(file_path)
        name, ext = os.path.splitext(basename)
        backup_path = backup_pattern.format(
            path=file_path,
            dir=dirname if dirname else '.',
            name=name,
            ext=ext,
            timestamp=timestamp
        )
        
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(backup_path), exist_ok=True)
    
    shutil.copy2(file_path, backup_path)
    return backup_path

def get_output_path(input_path, output_pattern=None, in_place=False):
    """Generate output path based on pattern or in-place flag."""
    if in_place:
        return input_path
    
    if output_pattern is None:
        # Default pattern: add _cropped before extension
        base, ext = os.path.splitext(input_path)
        return f"{base}_cropped{ext}"
    
    # Replace patterns in output_pattern
    dirname = os.path.dirname(input_path)
    basename = os.path.basename(input_path)
    name, ext = os.path.splitext(basename)
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    
    output_path = output_pattern.format(
        path=input_path,
        dir=dirname if dirname else '.',
        name=name,
        ext=ext,
        timestamp=timestamp
    )
    
    # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    return output_path

def crop_person(image_path, output_path, config=None):
    """Detect and crop person from image using configurable settings."""
    if config is None:
        config = DEFAULT_CONFIG.copy()
    
    # Initialize MediaPipe Pose
    mp_pose = mp.solutions.pose
    pose = mp_pose.Pose(
        static_image_mode=True,
        model_complexity=config['MODEL_COMPLEXITY'],
        min_detection_confidence=0.5
    )
    
    # Read image
    img = cv2.imread(image_path)
    if img is None:
        print(f"Error: Could not read image: {image_path}")
        return None
    
    # Process image
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    results = pose.process(img_rgb)
    
    if not results.pose_landmarks:
        print(f"No person detected in: {image_path}")
        return None
    
    # Get bounding box from visible landmarks
    h, w = img.shape[:2]
    landmarks = results.pose_landmarks.landmark
    
    visible_x_coords = []
    visible_y_coords = []
    
    for landmark in landmarks:
        if landmark.visibility > config['MIN_LANDMARK_VISIBILITY']:
            x = int(landmark.x * w)
            y = int(landmark.y * h)
            visible_x_coords.append(x)
            visible_y_coords.append(y)
    
    if not visible_x_coords:
        print(f"No visible landmarks detected in: {image_path}")
        return None
    
    # Calculate bounding box
    x1 = min(visible_x_coords)
    y1 = min(visible_y_coords)
    x2 = max(visible_x_coords)
    y2 = max(visible_y_coords)
    
    # Add padding
    padded_box = calculate_padding([x1, y1, x2, y2], img.shape, config)
    
    # Crop image
    x1, y1, x2, y2 = padded_box
    cropped_img = img[y1:y2, x1:x2]
    
    # Save cropped image
    cv2.imwrite(output_path, cropped_img)
    pose.close()
    
    return output_path

def process_files(paths, args):
    """Process multiple files or directories."""
    # Collect all image files
    image_files = []
    for path in paths:
        if os.path.isdir(path):
            # Process all images in directory
            for ext in ('*.jpg', '*.jpeg', '*.png'):
                image_files.extend(glob.glob(os.path.join(path, '**', ext), recursive=True))
        elif os.path.isfile(path):
            image_files.append(path)
        else:
            print(f"Warning: Path not found: {path}")
    
    if not image_files:
        print("No image files found to process")
        return
    
    # Configure padding
    config = DEFAULT_CONFIG.copy()
    if args.padding is not None:
        config['MIN_PADDING_PERCENT'] = args.padding
        config['MAX_PADDING_PERCENT'] = args.padding
    
    # Process each image
    success_count = 0
    for input_path in image_files:
        # Generate output path
        output_path = get_output_path(input_path, args.output_pattern, args.in_place)
        
        # Create backup if requested
        if args.backup_pattern is not None:
            backup_path = make_backup(input_path, args.backup_pattern)
            print(f"Created backup: {backup_path}")
        
        # Process image
        try:
            result = crop_person(input_path, output_path, config)
            if result:
                print(f"Processed: {input_path} -> {output_path}")
                success_count += 1
        except Exception as e:
            print(f"Error processing {input_path}: {str(e)}")
    
    print(f"\nProcessed {success_count} of {len(image_files)} files successfully")

def parse_args():
    parser = argparse.ArgumentParser(
        description='Detect and crop person from images with configurable padding.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Process a single image with 10% padding
  %(prog)s input.jpg --padding 10

  # Process multiple images in-place with backups
  %(prog)s *.jpg --in-place --backup-pattern "{dir}/backups/{name}{ext}.{timestamp}"

  # Process all images in a directory with custom output pattern
  %(prog)s photos/ --output-pattern "output/{name}_crop{ext}"

Pattern variables:
  {path}      Full original path
  {dir}       Directory path
  {name}      Filename without extension
  {ext}       File extension (with dot)
  {timestamp} Current timestamp (YYYY-MM-DD_HHMMSS)
        """
    )
    
    parser.add_argument('paths', nargs='+',
                      help='Input image files or directories')
    
    parser.add_argument('--padding', type=float,
                      help='Fixed padding percentage (overrides min/max padding)')
    
    parser.add_argument('--output-pattern',
                      help='Pattern for output filenames')
    
    parser.add_argument('--backup-pattern',
                      help='Pattern for backup filenames')
    
    parser.add_argument('--in-place', action='store_true',
                      help='Modify files in-place (requires --backup-pattern)')
    
    args = parser.parse_args()
    
    # Validate in-place editing requires backup
    if args.in_place and not args.backup_pattern:
        parser.error("--in-place requires --backup-pattern")
    
    return args

def main():
    check_dependencies()
    args = parse_args()
    process_files(args.paths, args)

if __name__ == "__main__":
    main()