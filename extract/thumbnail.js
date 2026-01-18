#!/usr/bin/env node

/**
 * Extract first I-frame thumbnail from video using ffmpeg
 * Usage: node extract-thumbnail.js <input-video> [output-image]
 */

const { exec } = require('child_process');
const { existsSync } = require('fs');
const path = require('path');

const inputFile = process.argv[2];
const outputFile = process.argv[3] || 'thumbnail.png';

if (!inputFile) {
  console.error('Usage: node extract-thumbnail.js <input-video> [output-image]');
  console.error('Example: node extract-thumbnail.js video.mp4 thumbnail.png');
  process.exit(1);
}

if (!existsSync(inputFile)) {
  console.error(`Error: Input file '${inputFile}' not found`);
  process.exit(1);
}

console.log(`Extracting first I-frame from: ${inputFile}`);
console.log(`Output will be saved to: ${outputFile}`);

// FFmpeg command to extract first I-frame
const ffmpegCmd = `ffmpeg -i "${inputFile}" -vf "select='eq(pict_type,I)'" -vframes 1 -q:v 2 "${outputFile}" -y`;

exec(ffmpegCmd, (error, stdout, stderr) => {
  if (error) {
    console.error(`✗ Failed to extract thumbnail: ${error.message}`);
    process.exit(1);
  }

  if (existsSync(outputFile)) {
    console.log(`✓ Thumbnail extracted successfully: ${outputFile}`);
  } else {
    console.error('✗ Thumbnail file was not created');
    process.exit(1);
  }
});
