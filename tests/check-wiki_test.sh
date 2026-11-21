#!/bin/sh
# Tests of plugins/playbook/scripts/check-wiki.sh. Run from the repository root.
check=plugins/playbook/scripts/check-wiki.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0
header='| ID | Date | Decision | Who | Their words |
|---|---|---|---|---|'

wiki() { # wiki <name>: a valid wiki with one work
  mkdir -p "$tmp/$1/works/a"
  printf '# W\n[a](works/a/spec.md)\n' > "$tmp/$1/README.md"
  printf '# Spec\n' > "$tmp/$1/works/a/spec.md"
  printf '%s\n| a-1 | d | x | O | "yes" |\n' "$header" > "$tmp/$1/works/a/decisions.md"
}
expect() { # expect <case> <exit> <text>
  out=$(sh "$check" "$tmp/$1"); code=$?
  if [ "$code" -ne "$2" ] || ! printf '%s\n' "$out" | grep -q "$3"; then
    printf 'not ok %s: exit %s, %s\n' "$1" "$code" "$out"; failed=1
  else
    printf 'ok %s\n' "$1"
  fi
}

wiki valid
expect valid 0 'check-wiki passed: 1 decisions'

wiki link; printf '[x](missing.md)\n' >> "$tmp/link/README.md"
expect link 1 'links to missing.md'

wiki old; mkdir -p "$tmp/old/works/h"; printf '[x](gone.md)\n' > "$tmp/old/works/h/notes.md"
expect old 0 'check-wiki passed'

wiki words; printf '| a-2 | d | y | O |  |\n' >> "$tmp/words/works/a/decisions.md"
expect words 1 'a-2 has no words'

wiki repeated; mkdir -p "$tmp/repeated/works/b"
printf '%s\n| a-1 | d | x | O | "si" |\n' "$header" > "$tmp/repeated/works/b/decisions.md"
expect repeated 1 'decision a-1 is repeated'

for w in replaced cited; do
  wiki $w
  printf '| a-2 | d | Replaced by a-3. y | O | "si" |\n| a-3 | d | z | O | "no" |\n' >> "$tmp/$w/works/a/decisions.md"
  printf 'Rule z (a-3).\n' > "$tmp/$w/product.md"
done
expect replaced 0 'check-wiki passed: 3 decisions'
printf 'Rule y (a-2).\n' >> "$tmp/cited/product.md"
expect cited 1 'product.md cites a-2, which is replaced'

exit $failed
