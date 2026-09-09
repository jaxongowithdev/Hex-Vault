#!/usr/bin/env bash
# Build App Store screenshots and a portrait preview video from stills in srcs/.
#
# Usage:
#   ./gen_store_assets.sh
#   ./gen_store_assets.sh --srcs ./srcs --out ./store-assets
#
# Requires: ffmpeg and ffprobe (brew install ffmpeg).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRCS_DIR="$ROOT/srcs"
OUT_DIR="$ROOT/store-assets"

# App Store Connect — 6.9" iPhone (iPhone 16/17 Pro Max class)
SHOT_W=1320
SHOT_H=2868
# App Store Connect — 6.5" iPhone (XS Max / 11 Pro Max)
SHOT_65_W=1242
SHOT_65_H=2688
# App preview — 6.9" portrait
PREV_W=886
PREV_H=1920
PREV_FPS=30
PREV_MIN=15
PREV_MAX=30
HOLD_DEFAULT=4

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Read PNG/JPG/WebP stills from srcs/ (sorted by name), write:
  store-assets/screenshots/iphone-6.9/NN.png   ${SHOT_W}x${SHOT_H}
  store-assets/screenshots/iphone-6.5/NN.png   ${SHOT_65_W}x${SHOT_65_H}
  store-assets/previews/iphone-6.9/preview.mp4 ${PREV_W}x${PREV_H} H.264 30fps AAC, ${PREV_MIN}-${PREV_MAX}s

Options:
  --srcs DIR     Source stills (default: ./srcs)
  --out DIR      Output root (default: ./store-assets)
  --hold SEC     Seconds each still is shown in the preview (default: ${HOLD_DEFAULT})
  -h, --help     Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --srcs) SRCS_DIR="$2"; shift 2 ;;
    --out) OUT_DIR="$2"; shift 2 ;;
    --hold) HOLD_DEFAULT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg not found. Install with: brew install ffmpeg" >&2
  exit 1
fi
if ! command -v ffprobe >/dev/null 2>&1; then
  echo "Error: ffprobe not found. Install with: brew install ffmpeg" >&2
  exit 1
fi

if [[ ! -d "$SRCS_DIR" ]]; then
  echo "Error: source directory not found: $SRCS_DIR" >&2
  exit 1
fi

IMAGES=()
while IFS= read -r f; do
  IMAGES+=("$f")
done < <(find "$SRCS_DIR" -type f \( \
    -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
  \) | LC_ALL=C sort)

if [[ ${#IMAGES[@]} -eq 0 ]]; then
  echo "Error: no PNG/JPG/WebP files in $SRCS_DIR" >&2
  echo "Put App Store stills in that folder, then re-run." >&2
  exit 1
fi

SHOT_69="$OUT_DIR/screenshots/iphone-6.9"
SHOT_65="$OUT_DIR/screenshots/iphone-6.5"
PREV_DIR="$OUT_DIR/previews/iphone-6.9"
WORK="$OUT_DIR/.work"

rm -rf "$WORK"
mkdir -p "$SHOT_69" "$SHOT_65" "$PREV_DIR" "$WORK"

echo "Found ${#IMAGES[@]} still(s) in $SRCS_DIR"
echo "Writing screenshots and preview under $OUT_DIR"

fit_png() {
  local src="$1" dest="$2" w="$3" h="$4"
  ffmpeg -y -hide_banner -loglevel error -i "$src" \
    -vf "scale=${w}:${h}:force_original_aspect_ratio=increase,crop=${w}:${h},format=rgb24" \
    -frames:v 1 "$dest"
}

i=0
for src in "${IMAGES[@]}"; do
  i=$((i + 1))
  name="$(printf '%02d.png' "$i")"
  echo "  screenshot $name  ←  $(basename "$src")"
  fit_png "$src" "$SHOT_69/$name" "$SHOT_W" "$SHOT_H"
  fit_png "$src" "$SHOT_65/$name" "$SHOT_65_W" "$SHOT_65_H"
  fit_png "$src" "$WORK/$name" "$PREV_W" "$PREV_H"
done

n=${#IMAGES[@]}
hold="$HOLD_DEFAULT"
read -r hold secs <<EOF
$(python3 -c "
hold=float('$HOLD_DEFAULT'); n=int('$n'); total=hold*n
lo=float('$PREV_MIN'); hi=float('$PREV_MAX')
if total < lo:
    hold = lo / n; total = lo
elif total > hi:
    hold = hi / n; total = hi
print('%.4f %.4f' % (hold, total))
")
EOF

PREVIEW="$PREV_DIR/preview.mp4"
echo "  preview   ${PREV_W}x${PREV_H}  ${n} clips × ${hold}s  →  ${secs}s"

rate="$(python3 -c "print(1.0/float('$hold'))")"
ffmpeg -y -hide_banner -loglevel error \
  -framerate "$rate" -i "$WORK/%02d.png" \
  -f lavfi -t "$secs" -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
  -vf "fps=${PREV_FPS},format=yuv420p" \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p -r "$PREV_FPS" -b:v 11M \
  -c:a aac -b:a 256k -ar 48000 -ac 2 \
  -shortest -movflags +faststart \
  "$PREVIEW"

rm -rf "$WORK"

echo
echo "Done."
echo "  6.9\" screenshots  $SHOT_69  (${n} × ${SHOT_W}x${SHOT_H})"
echo "  6.5\" screenshots  $SHOT_65  (${n} × ${SHOT_65_W}x${SHOT_65_H})"
echo "  Preview video     $PREVIEW"
ffprobe -v error -show_entries format=duration -show_entries stream=width,height,codec_name,avg_frame_rate \
  -of default=noprint_wrappers=1 "$PREVIEW"
