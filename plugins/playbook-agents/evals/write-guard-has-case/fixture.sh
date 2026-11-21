#!/bin/bash
set -eu
c=commit
git init -q -b main .
git config user.email eval@example.com
git config user.name "Andres Frei"
mkdir -p scripts
cat > scripts/check-version.sh <<'SH'
#!/bin/sh
# Prints the version of the VERSION file given as $1.
cat "$1"
SH
cat > scripts/check-version_test.sh <<'SH'
#!/bin/sh
d=$(mktemp -d)
printf '1.2.3\n' > "$d/VERSION"
out=$(sh scripts/check-version.sh "$d/VERSION") || { echo "FAIL: valid file"; exit 1; }
[ "$out" = "1.2.3" ] || { echo "FAIL: output"; exit 1; }
echo "ok"
SH
git add -A
git $c -q -m "feat: scaffold"
