#!/bin/bash
# Builds a repository with no settings of Claude Code.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
printf 'export const app = {};\n' > app.js
git add -A
git commit -q -m "feat: app"
