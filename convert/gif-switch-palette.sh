#!/bin/bash

# Usage: gif-switch-palette.sh <input_gif> <palette_png> <output_gif> [options]
if [ $# -lt 3 ]; then
    echo "Usage: $0 <input_gif> <palette_png> <output_gif> [options]"
    echo ""
    echo "Options:"
    echo "  -dither <mode>      Dithering mode (none, bayer, heckbert, floyd_steinberg, sierra2, sierra2_4a, default: bayer)"
    echo "  -bayer <scale>      Bayer dithering scale 0-5 (default: 5)"
    echo "  -fps <value>        Set frame rate (optional)"
    echo "  -scale <value>      Set scale (e.g., 720:-1, optional)"
    echo ""
    echo "e.g.:"
    echo "  $0 input.gif palette.png output.gif"
    echo "  $0 input.gif palette.png output.gif -dither floyd_steinberg"
    echo "  $0 input.gif palette.png output.gif -bayer 3"
    echo "  $0 input.gif palette.png output.gif -fps 15 -scale 720:-1"
    exit 1
fi

INPUT_GIF="$1"
PALETTE_PNG="$2"
OUTPUT_GIF="$3"
shift 3

# check if input files exist
if [ ! -f "$INPUT_GIF" ]; then
    echo "Error: Input GIF file not found: $INPUT_GIF"
    exit 1
fi

if [ ! -f "$PALETTE_PNG" ]; then
    echo "Error: Palette PNG file not found: $PALETTE_PNG"
    exit 1
fi

# defaults
DITHER="bayer"
BAYER_SCALE="5"
FPS=""
SCALE=""

# option parsing
while [[ $# -gt 0 ]]; do
    case $1 in
        -dither)
            DITHER="$2"
            shift 2
            ;;
        -bayer)
            BAYER_SCALE="$2"
            shift 2
            ;;
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

# Build filter chain
FILTERS=""

if [ -n "$FPS" ]; then
    FILTERS="fps=$FPS"
fi

if [ -n "$SCALE" ]; then
    if [ -n "$FILTERS" ]; then
        FILTERS="$FILTERS,scale=$SCALE:flags=lanczos"
    else
        FILTERS="scale=$SCALE:flags=lanczos"
    fi
fi

# Build paletteuse options
PALETTEUSE_OPTS="dither=$DITHER"
if [ "$DITHER" = "bayer" ]; then
    PALETTEUSE_OPTS="$PALETTEUSE_OPTS:bayer_scale=$BAYER_SCALE"
fi

# Build complete filter
if [ -n "$FILTERS" ]; then
    LAVFI="$FILTERS [x]; [x][1:v] paletteuse=$PALETTEUSE_OPTS"
else
    LAVFI="[0:v][1:v] paletteuse=$PALETTEUSE_OPTS"
fi

echo "Switching palette..."
echo "Input GIF: $INPUT_GIF"
echo "Palette: $PALETTE_PNG"
echo "Dither: $DITHER"
if [ "$DITHER" = "bayer" ]; then
    echo "Bayer scale: $BAYER_SCALE"
fi

# ffmpeg command
ffmpeg -i "$INPUT_GIF" -i "$PALETTE_PNG" -lavfi "$LAVFI" "$OUTPUT_GIF"

if [ $? -ne 0 ]; then
    echo "Error: Failed to apply palette"
    exit 1
fi

echo "Palette switch completed: $OUTPUT_GIF"
