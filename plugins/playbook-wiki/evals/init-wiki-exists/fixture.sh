#!/bin/bash
# Builds a repository whose wiki is at format 3, behind the playbook's.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki
printf '3\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Handmade shop

An online shop for handmade goods. The wiki wins over any other document.

Project owner: Laura Gómez.

| Page | Contains | Code it governs |
|------|----------|-----------------|
MD
git add -A
git commit -q -m "docs: wiki"
