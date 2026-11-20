#!/bin/sh
# Renders docs/assets/demo.html to docs/assets/demo.webp, 1200 px wide
# (readme-redesign-18). It draws the page at twice the size with a headless
# Chromium, then scales it down and encodes it with ffmpeg and libwebp.
# Chromium: the one named by CHROME, or the newest that Playwright keeps in
# ~/.cache/ms-playwright. The page loads its font from Google Fonts; without
# network the script stops and leaves demo.webp as it was.
# Usage: sh docs/assets/render-demo.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
chrome=${CHROME:-$(ls -d "$HOME"/.cache/ms-playwright/chromium-*/chrome-linux*/chrome 2>/dev/null |
  awk -F'/chromium-' '{ split($2, v, "/"); print v[1] "\t" $0 }' | sort -n | tail -n 1 | cut -f2)}
[ -n "$chrome" ] && [ -x "$chrome" ] || { printf 'no Chromium found: set CHROME\n' >&2; exit 1; }
for tool in ffmpeg curl; do
  command -v "$tool" >/dev/null || { printf '%s is missing\n' "$tool" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# The page takes its font from Google Fonts. Without it the image falls back
# to another font, so stop before rendering rather than overwrite demo.webp.
font='https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&display=block'
if ! curl -fsS --max-time 15 "$font" -o "$tmp/font.css" || ! grep -q 'fonts.gstatic.com' "$tmp/font.css"; then
  printf 'could not load IBM Plex Mono from Google Fonts: demo.webp left as it was\n' >&2
  exit 1
fi

if ! "$chrome" --headless --no-sandbox --disable-gpu --hide-scrollbars \
  --user-data-dir="$tmp/profile" --force-device-scale-factor=2 \
  --window-size=1200,600 --virtual-time-budget=5000 \
  --screenshot="$tmp/demo.png" "file://$here/demo.html" > "$tmp/chrome.log" 2>&1; then
  printf 'Chromium failed (%s):\n' "$chrome" >&2
  tail -n 20 "$tmp/chrome.log" >&2
  exit 1
fi
[ -s "$tmp/demo.png" ] || { printf 'Chromium wrote no screenshot\n' >&2; tail -n 20 "$tmp/chrome.log" >&2; exit 1; }
ffmpeg -v error -y -i "$tmp/demo.png" -vf scale=1200:-1:flags=lanczos \
  -c:v libwebp -lossless 0 -quality 92 "$tmp/demo.webp"
mv "$tmp/demo.webp" "$here/demo.webp"
printf '%s\n' "$here/demo.webp"
