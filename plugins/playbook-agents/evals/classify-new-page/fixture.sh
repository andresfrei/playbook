#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p docs/wiki
# A project with a wiki and no evidence page yet.
printf '# Project wiki\n\nOwner: Eval.\n' > docs/wiki/README.md
git add -A
git commit -q -m "docs: wiki"
