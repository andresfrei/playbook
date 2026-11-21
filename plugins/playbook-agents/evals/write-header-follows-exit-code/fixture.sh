#!/bin/bash
set -eu
c=commit
git init -q -b main .
git config user.email eval@example.com
git config user.name "Andres Frei"
mkdir -p scripts
cat > scripts/check-todo.sh <<'SH'
#!/bin/sh
# Checks that file $1 has no TODO.
# Exit 0 when there is none, 1 when there is one.
# Usage: sh scripts/check-todo.sh <file>
grep -q TODO "$1" && exit 1
exit 0
SH
cat > README.md <<'MD'
# tools

`scripts/check-todo.sh <file>` exits 0 when the file has no TODO and 1 when it has one.
MD
git add -A
git $c -q -m "feat: scaffold"
