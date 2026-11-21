#!/bin/sh
# check-wiki.sh [wiki]
# Checks a project's wiki: every relative link resolves, in the shared pages
# and in each work with a spec.md; every decision ID is unique; every decision
# has the decider's words. Prints one FAIL line per problem; exits 1 on any.
wiki=${1:-docs/wiki}
[ -f "$wiki/README.md" ] || { printf 'FAIL %s has no README.md\n' "$wiki"; exit 1; }

out=$(
  # Links.
  for page in "$wiki"/*.md "$wiki"/works/*/*.md; do
    [ -f "$page" ] || continue
    case $page in
      "$wiki"/works/*) [ -f "$(dirname "$page")/spec.md" ] || continue ;;
    esac
    dir=$(dirname "$page")
    grep -o '](\([^)]*\))' "$page" | sed 's/^](//; s/)$//; s/[[:space:]].*//; s/#.*//' |
      while IFS= read -r target; do
        case $target in ''|http://*|https://*|mailto:*) continue ;; esac
        [ -e "$dir/$target" ] || printf 'FAIL %s links to %s, which does not exist\n' "$page" "$target"
      done
  done
  # Decisions.
  for file in "$wiki"/works/*/decisions.md; do
    [ -f "$file" ] || continue
    awk -F '|' -v f="$file" '
      /^\|/ {
        id = $2; gsub(/^[ \t]+|[ \t]+$/, "", id)
        if (id == "ID" || id ~ /^-+$/ || id == "") next
        words = $6; gsub(/^[ \t]+|[ \t]+$/, "", words)
        if (words == "") printf "FAIL %s: %s has no words of the decider\n", f, id
        print "ID\t" id "\t" f
      }' "$file"
  done
)
fails=$(printf '%s\n' "$out" | grep '^FAIL')
dups=$(printf '%s\n' "$out" | awk -F '\t' '$1 == "ID" { n[$2]++; w[$2] = w[$2] " " $3 } END { for (i in n) if (n[i] > 1) printf "FAIL decision %s is repeated in%s\n", i, w[i] }')
all=$(printf '%s\n%s\n' "$fails" "$dups" | grep -v '^$')
if [ -n "$all" ]; then
  printf '%s\n' "$all"
  printf '%s check(s) failed\n' "$(printf '%s\n' "$all" | wc -l | tr -d ' ')"
  exit 1
fi
printf 'check-wiki passed: %s decisions\n' "$(printf '%s\n' "$out" | grep -c '^ID')"
