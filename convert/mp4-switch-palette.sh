#!/bin/bash

# Usage: mp4-switch-palette.sh <input_mp4> <palette_png> <output_mp4> [options]
if [ $# -lt 3 ]; then
    echo "Usage: $0 <input_mp4> <palette_png> <output_mp4> [options]"
    echo ""
    echo "Options:"
    echo "  -dither <mode>      Dithering mode (none, bayer, heckbert, floyd_steinberg, sierra2, sierra2_4a, default: bayer)"
    echo "  -bayer <scale>      Bayer dithering scale 0-5 (default: 5)"
    echo "  -fps <value>        Set frame rate (optional)"
    echo "  -scale <value>      Set scale (e.g., 1920:1080, -1:720)"
    echo "  -crf <value>        Set quality (0-51, lower is better, default: 18)"
    echo ""
    echo "e.g.:"
    echo "  $0 input.mp4 palette.png output.mp4"
    echo "  $0 input.mp4 palette.png output.mp4 -dither floyd_steinberg"
    echo "  $0 input.mp4 palette.png output.mp4 -scale 1280:-1 -crf 23"
    exit 1
fi

INPUT_MP4="$1"
PALETTE_PNG="$2"
OUTPUT_MP4="$3"
shift 3

# check if input files exist
if [ ! -f "$INPUT_MP4" ]; then
    echo "Error: Input MP4 file not found: $INPUT_MP4"
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
CRF="18"

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
        -crf)
            CRF="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Build filter chain start
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

# H.264 requires even-numbered resolution (apply padding/scale before paletteuse? No, usually after or during scale)
# But here we are mapping colors.
# Let's apply scale first.
# Also we need to make sure the output commands know to pad if necessary, but paletteuse doesn't change resolution.
# We will add pad filter at the end if we scaled just to be safe for h264, or just trust the user/ffmpeg auto-pad in complex filters isn't always automatic.
# Let's add explicit padding logic similar to gif-to-mp4.sh but adapted for complex filter chain

# If we have filters so far (fps, scale), we assume stream [0:v] goes into them.
# We need to construct the graph.

# Build paletteuse options
PALETTEUSE_OPTS="dither=$DITHER"
if [ "$DITHER" = "bayer" ]; then
    PALETTEUSE_OPTS="$PALETTEUSE_OPTS:bayer_scale=$BAYER_SCALE"
fi

# Constructing the complex filter graph
# [0:v] -> [fps/scale] -> [padded] -> [paletteuse] -> [out]
# Notes: H.264 needs even dimensions. Pad should happen before encoding.
# Paletteuse output will be the same resolution as its input.

FILTER_CHAIN=""

# Add FPS/Scale if present
if [ -n "$FILTERS" ]; then
    FILTER_CHAIN="$FILTERS,"
fi

# Add pad filter to ensure even dimensions for libx264
FILTER_CHAIN="${FILTER_CHAIN}pad=ceil(iw/2)*2:ceil(ih/2)*2"

# Now connect to paletteuse
# [0:v] FILTER_CHAIN [v_processed]; [v_processed][1:v] paletteuse [out]

LAVFI="[0:v]${FILTER_CHAIN}[v_processed];[v_processed][1:v]paletteuse=$PALETTEUSE_OPTS[out]"

echo "Switching palette..."
echo "Input MP4: $INPUT_MP4"
echo "Palette: $PALETTE_PNG"
echo "Dither: $DITHER"
if [ "$DITHER" = "bayer" ]; then
    echo "Bayer scale: $BAYER_SCALE"
fi
echo "Output: $OUTPUT_MP4"

# ffmpeg command
# -map "[out]" explicitly maps the output of the filter graph to the output file
ffmpeg -i "$INPUT_MP4" -i "$PALETTE_PNG" -filter_complex "$LAVFI" -map "[out]" \
    -c:v libx264 -pix_fmt yuv420p -crf "$CRF" -movflags +faststart \
    -an \
    "$OUTPUT_MP4"

if [ $? -ne 0 ]; then
    echo "Error: Failed to apply palette"
    exit 1
fi

echo "MP4 palette switch completed: $OUTPUT_MP4"
