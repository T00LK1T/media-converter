#!/bin/bash

# Usage: ./extract-thumbnail.sh <input-video> <output-image>
# Example: ./extract-thumbnail.sh video.mp4 thumbnail.png

INPUT_FILE="$1"
OUTPUT_FILE="${2:-thumbnail.png}"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input-video> [output-image]"
    echo "Example: $0 video.mp4 thumbnail.png"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

echo "Extracting first I-frame from: $INPUT_FILE"
echo "Output will be saved to: $OUTPUT_FILE"

# Extract the first I-frame
ffmpeg -i "$INPUT_FILE" \
    -vf "select='eq(pict_type,I)'" \
    -vframes 1 \
    -q:v 2 \
    "$OUTPUT_FILE" \
    -y

if [ $? -eq 0 ]; then
    echo "✓ Thumbnail extracted successfully: $OUTPUT_FILE"
else
    echo "✗ Failed to extract thumbnail"
    exit 1
fi
