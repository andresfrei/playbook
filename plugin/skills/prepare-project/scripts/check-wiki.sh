#!/bin/sh
# Checks a project's wiki against two rules of references/1-wiki.md.
# Usage: sh check-wiki.sh [wiki directory]    (default: docs/wiki)
# It fails when "Where work stands" in README.md has more than 250 words, or
# when a relative link in a page does not resolve to a file or a directory.
# Not checked: reference-style links ([text][id]), and a link whose target
# holds a space, a parenthesis, or a percent-encoded character.
# Exits 0 when both hold, 1 otherwise.
set -u

wiki=${1:-docs/wiki}
wiki=${wiki%/}
max_state_words=250

if [ ! -f "$wiki/README.md" ]; then
  printf 'FAIL %s has no README.md\n' "$wiki"
  exit 1
fi

failures=0

# The start of both awk programs: it drops a carriage return at the end of a
# line and sets "fenced" inside a fenced code block, which ends only at the
# marker that opened it.
fences='{ sub(/\r$/, "") }
/^[ \t]*(```|~~~)/ {
  mark = ($0 ~ /^[ \t]*```/) ? "`" : "~"
  if (!fenced) { fenced = 1; opened = mark } else if (mark == opened) fenced = 0
  next
}'

# The words under the heading "Where work stands", whatever its level and
# whatever follows the title, up to the next heading of its level or above.
# Prints "none" when the page has no such heading.
state_words=$(awk "$fences"'
  !fenced && /^#+[ \t]/ {
    match($0, /^#+/)
    if ($0 ~ /^#+[ \t]+Where work stands/) { inside = 1; found = 1; level = RLENGTH; next }
    if (inside && RLENGTH <= level) inside = 0
  }
  inside { words += NF }
  END { if (found) print words + 0; else print "none" }' "$wiki/README.md")
if [ "$state_words" = none ]; then
  printf 'note: %s/README.md has no "Where work stands" section\n' "$wiki"
elif [ "$state_words" -gt "$max_state_words" ]; then
  printf 'FAIL "Where work stands" has %s words, limit %s\n' "$state_words" "$max_state_words"
  failures=$((failures + 1))
fi

# Prints the target of each relative link of a page, one per line. It skips
# fenced code blocks, code spans, addresses with a scheme, anchors of the same
# page, and absolute paths, and drops the anchor and the title of a target.
link_targets() {
  awk "$fences"'
    fenced { next }
    {
      line = $0
      gsub(/`[^`]*`/, "", line)
      while (match(line, /\]\([^)]*\)/)) {
        target = substr(line, RSTART + 2, RLENGTH - 3)
        line = substr(line, RSTART + RLENGTH)
        sub(/^[ \t]+/, "", target)
        sub(/[ \t].*$/, "", target)
        sub(/#.*$/, "", target)
        if (target == "" || target ~ /^\// || target ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) continue
        print target
      }
    }' "$1"
}

# The slash makes find enter a wiki directory that is a link.
broken=$(
  find "$wiki/" -name '*.md' | sort | while IFS= read -r page; do
    link_targets "$page" | while IFS= read -r target; do
      [ -e "$(dirname "$page")/$target" ] ||
        printf 'FAIL %s links to %s, which does not exist\n' "$page" "$target"
    done
  done
)
if [ -n "$broken" ]; then
  printf '%s\n' "$broken"
  failures=$((failures + $(printf '%s\n' "$broken" | wc -l | tr -d ' ')))
fi

if [ "$failures" -gt 0 ]; then
  printf '%s check(s) failed\n' "$failures"
  exit 1
fi
if [ "$state_words" = none ]; then
  printf 'check-wiki passed: every relative link resolves\n'
else
  printf 'check-wiki passed: "Where work stands" has %s words, limit %s\n' \
    "$state_words" "$max_state_words"
fi
