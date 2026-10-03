#!/usr/bin/env bash
# Encode the README example clips from the PNG frames the rec-*.cjs recorders wrote.
# Usage (from the scratch dir where `npm i playwright ffmpeg-static` ran and frames/ lives):
#   bash <repo>/docs/assets/examples/record/encode.sh [out-dir]
# Output: directions.webp (960×600, 3 segments cross-faded 0.25 s), dashboard.webp (960×600), ship.webp (960×420); all 24 fps, loop forever.
set -euo pipefail
OUT="${1:-.}"; FR="${OUT_DIR:-frames}"
FF="$(node -p "require('ffmpeg-static')")"
"$FF" -y -loglevel error -framerate 24 -i "$FR/ledger/f%04d.png" -framerate 24 -i "$FR/monolith/f%04d.png" -framerate 24 -i "$FR/atelier/f%04d.png" \
  -filter_complex "[0][1]xfade=transition=fade:duration=0.25:offset=3.15[v1];[v1][2]xfade=transition=fade:duration=0.25:offset=6.3[v2];[v2]scale=960:-1:flags=lanczos" \
  -c:v libwebp_anim -quality 76 -compression_level 6 -loop 0 "$OUT/directions.webp"
"$FF" -y -loglevel error -framerate 24 -i "$FR/dashboard/f%04d.png" -vf "scale=960:-1:flags=lanczos" -c:v libwebp_anim -quality 76 -compression_level 6 -loop 0 "$OUT/dashboard.webp"
"$FF" -y -loglevel error -framerate 24 -i "$FR/ship/f%04d.png" -vf "scale=960:-1:flags=lanczos" -c:v libwebp_anim -quality 80 -compression_level 6 -loop 0 "$OUT/ship.webp"
ls -la "$OUT"/directions.webp "$OUT"/dashboard.webp "$OUT"/ship.webp
