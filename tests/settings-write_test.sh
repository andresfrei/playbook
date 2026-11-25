#!/bin/sh
# Tests of plugins/playbook/scripts/settings-write.sh. Run from the repository root.
script=$PWD/plugins/playbook/scripts/settings-write.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0

ok() { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; failed=1; }
# check NAME FILE JQ-EXPR: the expression must be true for FILE.
check() { if jq -e "$3" "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }
# refused NAME FILE ARGS...: exits non-zero, prints on stderr, FILE unchanged.
refused() {
  name=$1; f=$2; shift 2
  before=$(cat "$f" 2>/dev/null; echo x)
  if sh "$script" "$@" 2>"$tmp/err"; then bad "$name (exit 0)"; return; fi
  after=$(cat "$f" 2>/dev/null; echo x)
  if [ -s "$tmp/err" ] && [ "$before" = "$after" ]; then ok "$name"; else bad "$name"; fi
}

# Rules added once, idempotent, deduped, missing file and folder created.
f=$tmp/new/dir/settings.json
sh "$script" rule "$f" allow 'Bash(ls)' 'Read' 'Bash(ls)' || bad "rule on missing file"
check "creates file with deduped rules" "$f" '.permissions.allow == ["Bash(ls)","Read"]'
cp "$f" "$tmp/first.json"
sh "$script" rule "$f" allow 'Bash(ls)' 'Read'
if cmp -s "$f" "$tmp/first.json"; then ok "second run gives the same file"; else bad "second run gives the same file"; fi

# Other keys and existing rules kept; new rules appended after them.
f=$tmp/keep.json
printf '{"outputStyle":"x","permissions":{"defaultMode":"plan","allow":["Old"],"deny":["D"]}}' > "$f"
sh "$script" rule "$f" allow New Old
check "existing rules first, then new" "$f" '.permissions.allow == ["Old","New"]'
check "other keys kept" "$f" '.outputStyle == "x" and .permissions.defaultMode == "plan" and .permissions.deny == ["D"]'
sh "$script" rule "$f" ask 'Edit'
check "ask array created" "$f" '.permissions.ask == ["Edit"] and .permissions.allow == ["Old","New"]'

# Quotes and spaces stored literally; a rule starting with a dash too.
f=$tmp/quote.json
sh "$script" rule "$f" deny 'Bash(npm run "test x")' '-odd'
check "quotes and spaces literal" "$f" '.permissions.deny == ["Bash(npm run \"test x\")","-odd"]'

# Attribution.
f=$tmp/attr.json
printf '{"outputStyle":"x"}' > "$f"
sh "$script" attribution "$f" none
check "attribution none" "$f" '.attribution == {"commit":"","pr":""} and .outputStyle == "x"'
printf '{"attribution":false}' > "$f"
sh "$script" attribution "$f" commit
check "commit on attribution false" "$f" '.attribution == {"commit":""}'
sh "$script" attribution "$f" pr
check "pr keeps commit" "$f" '.attribution == {"commit":"","pr":""}'
printf '{"attribution":{"commit":"hi"}}' > "$f"
sh "$script" attribution "$f" pr
check "pr keeps other keys" "$f" '.attribution == {"commit":"hi","pr":""}'
f=$tmp/attr2.json
sh "$script" attribution "$f" pr
check "pr on missing file" "$f" '.attribution == {"pr":""}'

# Refusals.
printf '{broken' > "$tmp/broken.json"
refused "broken JSON refused" "$tmp/broken.json" rule "$tmp/broken.json" allow X
printf '[1]' > "$tmp/array.json"
refused "array top level refused" "$tmp/array.json" attribution "$tmp/array.json" none
printf '{"a":1}' > "$tmp/target.json"
ln -s "$tmp/target.json" "$tmp/link.json"
refused "symlink refused" "$tmp/target.json" rule "$tmp/link.json" allow X
if [ -L "$tmp/link.json" ]; then ok "symlink kept"; else bad "symlink kept"; fi
printf '{"a":1}' > "$tmp/u.json"
refused "unknown kind refused" "$tmp/u.json" rule "$tmp/u.json" maybe X
refused "no rule refused" "$tmp/u.json" rule "$tmp/u.json" allow
refused "unknown value refused" "$tmp/u.json" attribution "$tmp/u.json" both
refused "unknown command refused" "$tmp/u.json" remove "$tmp/u.json" allow X

# Missing jq: a PATH with the basic tools and no jq.
bin=$tmp/bin
mkdir -p "$bin"
for t in sh cat dirname mkdir mktemp mv rm cp chmod printf; do
  p=$(command -v "$t") && case $p in /*) ln -s "$p" "$bin/$t" ;; esac
done
if PATH=$bin sh "$script" rule "$tmp/nojq.json" allow X 2>"$tmp/err"; then
  bad "missing jq exits non-zero"
else
  if grep -q jq "$tmp/err" && [ ! -e "$tmp/nojq.json" ]; then ok "missing jq refused, nothing written"; else bad "missing jq refused, nothing written"; fi
fi
left=0
for t in "$tmp"/.settings-write.*; do [ -e "$t" ] && left=1; done
if [ "$left" = 0 ]; then ok "no temp files left"; else bad "no temp files left"; fi

exit "$failed"
