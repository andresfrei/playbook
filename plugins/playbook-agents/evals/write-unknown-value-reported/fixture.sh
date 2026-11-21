#!/bin/bash
set -eu
c=commit
git init -q -b main .
git config user.email eval@example.com
git config user.name "Andres Frei"
mkdir -p scripts
cat > scripts/level.sh <<'SH'
#!/bin/sh
# Prints the word for the "level:" field of the front matter of file $1.
v=$(sed -n 's/^level: *//p' "$1" | head -n 1)
case $v in
  1) echo low ;;
  2) echo medium ;;
esac
SH
printf -- '---\nlevel: 2\n---\nbody\n' > sample.md
git add -A
git $c -q -m "feat: scaffold"
