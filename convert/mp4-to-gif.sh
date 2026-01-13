#!/bin/bash

# Usage: mp4-to-gif.sh <input_mp4> <output_gif> [options]
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_mp4> <output_gif> [options]"
    echo ""
    echo "Options:"
    echo "  -fps <value>        Set frame rate (default: 15)"
    echo "  -scale <value>      Set scale (e.g., 1920:1080, -1:720, 720:-1)"
    echo "  -colors <value>     Max colors in palette (default: 256, max: 256)"
    echo "  -palette <file>     Use custom palette file (skips palette generation)"
    echo ""
    echo "e.g.:"
    echo "  $0 input.mp4 output.gif"
    echo "  $0 input.mp4 output.gif -fps 10"
    echo "  $0 input.mp4 output.gif -fps 15 -scale 720:-1"
    echo "  $0 input.mp4 output.gif -scale 480:-1 -colors 128"
    echo "  $0 input.mp4 output.gif -palette custom_palette.png"
    exit 1
fi

INPUT_MP4="$1"
OUTPUT_GIF="$2"
shift 2

# check if input file exists
if [ ! -f "$INPUT_MP4" ]; then
    echo "Error: Input MP4 file not found: $INPUT_MP4"
    exit 1
fi

# defaults
FPS="15"
SCALE=""
COLORS="256"
PALETTE=""

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
        -colors)
            COLORS="$2"
            shift 2
            ;;
        -palette)
            PALETTE="$2"
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

# palette file handling
USE_TEMP_PALETTE=false

if [ -n "$PALETTE" ]; then
    # Use provided palette
    if [ ! -f "$PALETTE" ]; then
        echo "Error: Palette file not found: $PALETTE"
        exit 1
    fi
    PALETTE_FILE="$PALETTE"
    echo "Using custom palette: $PALETTE_FILE"
else
    # Generate temporary palette
    USE_TEMP_PALETTE=true
    PALETTE_FILE=$(mktemp /tmp/palette_XXXXXX.png)

    echo "Generating palette..."
    # Generate palette (first pass)
    ffmpeg -y -i "$INPUT_MP4" -vf "$FILTERS,palettegen=max_colors=$COLORS:stats_mode=diff" "$PALETTE_FILE"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to generate palette"
        rm -f "$PALETTE_FILE"
        exit 1
    fi
fi

echo "Converting to GIF..."
# Generate GIF using palette (second pass)
ffmpeg -i "$INPUT_MP4" -i "$PALETTE_FILE" -lavfi "$FILTERS [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=5" "$OUTPUT_GIF"

if [ $? -ne 0 ]; then
    echo "Error: Failed to convert to GIF"
    rm -f "$PALETTE_FILE"
    exit 1
fi

# cleanup (only remove temporary palette)
if [ "$USE_TEMP_PALETTE" = true ]; then
    rm -f "$PALETTE_FILE"
fi

echo "GIF conversion completed: $OUTPUT_GIF"
