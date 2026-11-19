#!/bin/bash
# Builds a repository already started, with code, a README, and a CLAUDE.md,
# and no wiki.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p src
printf '# Handmade shop\n\nAn online shop where artisans sell handmade goods to buyers.\n' > README.md
printf '# Notes\n\nRun `npm test` before a commit.\n' > CLAUDE.md
printf 'export const cart = [];\n' > src/cart.js
git add -A
git commit -q -m "feat: shop"
