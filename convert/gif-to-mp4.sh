#!/bin/bash

# Usage: gif-mp4.sh <input_gif> <output_mp4> [options]
if [ $# -lt 2 ]; then
    echo "Usage: $0 <input_gif> <output_mp4> [options]"
    echo ""
    echo "Options:"
    echo "  -fps <value>        Set frame rate (default: keep original)"
    echo "  -scale <value>      Set scale (e.g., 1920:1080, -1:720)"
    echo "  -crf <value>        Set quality (0-51, lower is better, default: 18)"
    echo ""
    echo "e.g.:"
    echo "  $0 input.gif output.mp4"
    echo "  $0 input.gif output.mp4 -fps 30"
    echo "  $0 input.gif output.mp4 -fps 30 -crf 23"
    echo "  $0 input.gif output.mp4 -scale 1920:-1"
    exit 1
fi

INPUT_GIF="$1"
OUTPUT_MP4="$2"
shift 2

# check if input file exists
if [ ! -f "$INPUT_GIF" ]; then
    echo "Error: Input GIF file not found: $INPUT_GIF"
    exit 1
fi

# defaults
FPS=""
SCALE=""
CRF="18"

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

# filter construction
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

# H.264 requires even-numbered resolution (auto padding)
if [ -n "$FILTERS" ]; then
    FILTERS="$FILTERS,pad=ceil(iw/2)*2:ceil(ih/2)*2"
else
    FILTERS="pad=ceil(iw/2)*2:ceil(ih/2)*2"
fi

# ffmpeg command
ffmpeg -i "$INPUT_GIF" -vf "$FILTERS" -c:v libx264 -pix_fmt yuv420p -crf "$CRF" -movflags +faststart "$OUTPUT_MP4"

echo "MP4 conversion completed: $OUTPUT_MP4"
