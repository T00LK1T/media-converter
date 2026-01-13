#!/bin/bash

# Usage: extract-palette.sh <input_video> <output_palette.png> [options]
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_video> <output_palette.png> [options]"
    echo ""
    echo "Options:"
    echo "  -fps <value>        Set frame rate for palette extraction (default: 15)"
    echo "  -scale <value>      Set scale for palette extraction (e.g., 1920:1080, -1:720)"
    echo ""
    echo "e.g.:"
    echo "  $0 input.mp4 palette.png"
    echo "  $0 input.mp4 palette.png -fps 10"
    echo "  $0 input.mp4 palette.png -scale 1280:-1"
    exit 1
fi

INPUT_VIDEO="$1"
OUTPUT_PALETTE="$2"
shift 2
# check if input file exists
if [ ! -f "$INPUT_VIDEO" ]; then
    echo "Error: Input video file not found: $INPUT_VIDEO"
    exit 1
fi
# defaults
FPS="15"
SCALE=""
# option parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -fps)
            FPS="$2"
            shift 2
            ;;
        -scale)
            SCALE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
# filter construction
FILTERS="fps=$FPS"

if [ -n "$SCALE" ]; then
    FILTERS="$FILTERS,scale=$SCALE:flags=lanczos"
fi

# ffmpeg command
ffmpeg -y -i "$INPUT_VIDEO" -vf "$FILTERS,palettegen=max_colors=256:stats_mode=diff" "$OUTPUT_PALETTE"
