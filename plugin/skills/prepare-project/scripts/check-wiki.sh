#!/bin/sh
# Checks a project's wiki against four rules of references/1-wiki.md.
# Usage: sh check-wiki.sh [wiki directory]    (default: docs/wiki)
#        sh check-wiki.sh --rows [wiki directory]
# It fails when:
# - "Where work stands" in README.md has more than 250 words;
# - a relative link in a page does not resolve to a file or a directory;
# - a path that the wiki names as code does not exist in the project: a path
#   in the column "Code it governs" of a table of README.md, or in the first
#   column of a table under a heading "Code on the old definition" of any page;
# - a row of decisions.md has more than 60 words of decision text.
# A path is the text of a code span, and it is read from the project's root,
# which is two directories above the wiki. The rows of decisions.md that are
# checked are the ones after the first rows that .unchecked-decisions counts;
# a wiki without that file has no row checked.
# With --rows it prints how many rows decisions.md holds, and checks nothing.
# Not checked: reference-style links ([text][id]); a link whose target holds a
# space, a parenthesis, or a percent-encoded character; and a table cell or a
# code span that holds the character "|".
# Exits 0 when every rule holds, 1 otherwise.
set -u

rows_only=0
if [ "${1:-}" = "--rows" ]; then
  rows_only=1
  shift
fi
wiki=${1:-docs/wiki}
wiki=${wiki%/}
project="$wiki/../.."
max_state_words=250
max_decision_words=60

if [ ! -f "$wiki/README.md" ]; then
  printf 'FAIL %s has no README.md\n' "$wiki"
  exit 1
fi

failures=0

# The start of every awk program: it drops a carriage return at the end of a
# line and sets "fenced" inside a fenced code block, which ends only at the
# marker that opened it.
fences='{ sub(/\r$/, "") }
/^[ \t]*(```|~~~)/ {
  mark = ($0 ~ /^[ \t]*```/) ? "`" : "~"
  if (!fenced) { fenced = 1; opened = mark } else if (mark == opened) fenced = 0
  next
}'

# Reads the rows of decisions.md: the lines of a table whose first cell is an
# identifier such as D12 or TD3. With mode "count" it prints how many there
# are. Otherwise it prints one line for each row after the first <skip> whose
# decision, the third cell, has more than <max> words.
decision_rows() {
  [ -f "$wiki/decisions.md" ] || { [ "$1" = count ] && printf '0\n'; return 0; }
  awk -v mode="$1" -v skip="${2:-0}" -v max="$max_decision_words" "$fences"'
    fenced { next }
    /^[ \t]*\|/ {
      split($0, cell, "|")
      id = cell[2]
      gsub(/[ \t]/, "", id)
      if (id !~ /^[A-Z]+[0-9]+$/) next
      rows++
      if (mode == "count" || rows <= skip) next
      words = split(cell[4], word, " ")
      if (words > max)
        printf "FAIL decisions.md: the decision of %s has %d words, limit %d\n", id, words, max
    }
    END { if (mode == "count") print rows + 0 }' "$wiki/decisions.md"
}

if [ "$rows_only" -eq 1 ]; then
  decision_rows count
  exit 0
fi

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

# Prints each path that a page names as code, one per line: the code spans of
# the column "Code it governs" of a table, and of the first column of a table
# under a heading "Code on the old definition". It skips fenced code blocks.
code_paths() {
  awk "$fences"'
    function spans(text) {
      while (match(text, /`[^`]+`/)) {
        print substr(text, RSTART + 1, RLENGTH - 2)
        text = substr(text, RSTART + RLENGTH)
      }
    }
    fenced { next }
    /^#+[ \t]/ {
      match($0, /^#+/)
      if ($0 ~ /^#+[ \t]+Code on the old definition/) { old = 1; level = RLENGTH; next }
      if (old && RLENGTH <= level) old = 0
    }
    /^[ \t]*\|/ {
      cells = split($0, cell, "|")
      if (old) spans(cell[2])
      if (column) spans(cell[column])
      else for (i = 2; i < cells; i++) {
        title = cell[i]
        gsub(/^[ \t]+|[ \t]+$/, "", title)
        if (title == "Code it governs") column = i
      }
      next
    }
    { column = 0 }' "$1"
}

missing=$(
  find "$wiki/" -name '*.md' | sort | while IFS= read -r page; do
    code_paths "$page" | while IFS= read -r path; do
      [ -e "$project/$path" ] ||
        printf 'FAIL %s names the path %s, which does not exist in the project\n' "$page" "$path"
    done
  done
)
if [ -n "$missing" ]; then
  printf '%s\n' "$missing"
  failures=$((failures + $(printf '%s\n' "$missing" | wc -l | tr -d ' ')))
fi

# The rows of decisions.md written after the wiki reached the format that
# limits them. The file holds how many rows were there before.
if [ -f "$wiki/.unchecked-decisions" ]; then
  unchecked=$(head -n 1 "$wiki/.unchecked-decisions" | tr -d ' \t\r')
  case $unchecked in
    ''|*[!0-9]*|??????????*)
      printf 'FAIL %s/.unchecked-decisions does not hold a number\n' "$wiki"
      failures=$((failures + 1)) ;;
    *)
      long=$(decision_rows check "$unchecked")
      if [ -n "$long" ]; then
        printf '%s\n' "$long"
        failures=$((failures + $(printf '%s\n' "$long" | wc -l | tr -d ' ')))
      fi ;;
  esac
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
