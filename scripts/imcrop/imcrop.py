#!/usr/bin/env nix
#!nix shell --impure --file deps.nix
#!nix --command python

import sys
import os
import cv2
import mediapipe as mp
import numpy as np

# Configuration - Easy to modify these parameters
CONFIG = {
    # Padding settings
    'MIN_PADDING_PERCENT': 8,    # Minimum padding around person
    'MAX_PADDING_PERCENT': 25,   # Maximum padding for small subjects
    'MIN_PADDING_PIXELS': 30,    # Minimum padding in absolute pixels
    
    # Aspect ratio settings
    'MAX_ASPECT_RATIO': 1.5,     # Maximum width/height ratio
    'MIN_ASPECT_RATIO': 0.5,     # Minimum width/height ratio
    
    # Detection settings
    'MIN_LANDMARK_VISIBILITY': 0.5,  # Minimum visibility for landmarks
    'MODEL_COMPLEXITY': 1,           # MediaPipe model complexity (0, 1, or 2)
    
    # Debug settings
    'SAVE_DEBUG_IMAGES': False,      # Save debug visualization
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

def calculate_padding(bbox, img_shape, config=CONFIG):
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

def crop_person(image_path, config=CONFIG):
    """Detect and crop person from image using configurable settings."""
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
        print("No person detected in the image")
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
        print("No visible landmarks detected")
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
    
    # Save results
    base_name = os.path.splitext(image_path)[0]
    output_path = f"{base_name}_cropped.jpg"
    cv2.imwrite(output_path, cropped_img)
    
    # Save debug visualization if enabled
    if config['SAVE_DEBUG_IMAGES']:
        debug_img = img.copy()
        # Original detection
        cv2.rectangle(debug_img, (x1, y1), (x2, y2), (0, 255, 0), 2)
        # Padded crop area
        cv2.rectangle(debug_img, (int(padded_box[0]), int(padded_box[1])), 
                     (int(padded_box[2]), int(padded_box[3])), (0, 0, 255), 2)
        cv2.imwrite(f"{base_name}_debug.jpg", debug_img)
    
    pose.close()
    return output_path

def main():
    check_dependencies()
    
    if len(sys.argv) < 2:
        print("Usage: ./script.py <image_path> [min_padding_percent]")
        print("Edit the CONFIG dictionary at the top of the script to adjust other parameters")
        sys.exit(1)
    
    image_path = sys.argv[1]
    
    # Allow override of minimum padding from command line
    if len(sys.argv) > 2:
        CONFIG['MIN_PADDING_PERCENT'] = float(sys.argv[2])
    
    # Enable debug images if DEBUG environment variable is set
    if os.environ.get('DEBUG', '0') == '1':
        CONFIG['SAVE_DEBUG_IMAGES'] = True
    
    if not os.path.exists(image_path):
        print(f"Error: Image file not found: {image_path}")
        sys.exit(1)
    
    output_path = crop_person(image_path, CONFIG)
    
    if output_path:
        print(f"Successfully created: {output_path}")
    else:
        print("Failed to process image")
        sys.exit(1)

if __name__ == "__main__":
    main()