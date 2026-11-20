#!/bin/sh
# Renders docs/assets/demo.html to docs/assets/demo.webp, 1200 px wide
# (readme-redesign-18). It draws the page at twice the size with a headless
# Chromium, then scales it down and encodes it with ffmpeg and libwebp.
# Chromium: the one named by CHROME, or the newest that Playwright keeps in
# ~/.cache/ms-playwright. The page loads its font from Google Fonts.
# Usage: sh docs/assets/render-demo.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
chrome=${CHROME:-$(ls -d "$HOME"/.cache/ms-playwright/chromium-*/chrome-linux*/chrome 2>/dev/null |
  awk -F'/chromium-' '{ split($2, v, "/"); print v[1] "\t" $0 }' | sort -n | tail -n 1 | cut -f2)}
[ -n "$chrome" ] && [ -x "$chrome" ] || { printf 'no Chromium found: set CHROME\n' >&2; exit 1; }
command -v ffmpeg >/dev/null || { printf 'ffmpeg is missing\n' >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
"$chrome" --headless --no-sandbox --disable-gpu --hide-scrollbars \
  --user-data-dir="$tmp/profile" --force-device-scale-factor=2 \
  --window-size=1200,600 --virtual-time-budget=5000 \
  --screenshot="$tmp/demo.png" "file://$here/demo.html" >/dev/null 2>&1
[ -s "$tmp/demo.png" ] || { printf 'Chromium wrote no screenshot\n' >&2; exit 1; }
ffmpeg -v error -y -i "$tmp/demo.png" -vf scale=1200:-1:flags=lanczos \
  -c:v libwebp -lossless 0 -quality 92 "$here/demo.webp"
printf '%s\n' "$here/demo.webp"
