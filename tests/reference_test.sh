#!/bin/sh
# Tests that every skill, agent, and hook script of the plugin has a page in
# docs/reference/, and that the index links every page. Run from the repository
# root. SKILLS, AGENTS, HOOKS, and REF override the checked folders.
SKILLS=${SKILLS:-plugins/playbook/skills}
AGENTS=${AGENTS:-plugins/playbook/agents}
HOOKS=${HOOKS:-plugins/playbook/hooks}
REF=${REF:-docs/reference}

# problems: prints one line per page missing or not linked.
problems() {
  for d in "$SKILLS"/*/; do
    [ -d "$d" ] || continue
    [ -f "$REF/$(basename "$d").md" ] || printf 'no page for skill %s\n' "$(basename "$d")"
  done
  for f in "$AGENTS"/*.md; do
    [ -f "$f" ] && [ ! -f "$REF/$(basename "$f")" ] && printf 'no page for agent %s\n' "$(basename "$f" .md)"
  done
  for f in "$HOOKS"/*.sh; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = lib.sh ] && continue
    [ -f "$REF/$(basename "$f" .sh).md" ] || printf 'no page for hook %s\n' "$(basename "$f" .sh)"
  done
  for f in "$REF"/*.md; do
    [ -f "$f" ] || continue
    n=$(basename "$f")
    [ "$n" = README.md ] && continue
    grep -qF "($n)" "$REF/README.md" 2>/dev/null || printf 'index does not link %s\n' "$n"
  done
}

failed=0
out=$(problems)
if [ -n "$out" ]; then printf 'not ok reference: %s\n' "$out"; failed=1; else echo 'ok reference'; fi

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
cp -R "$REF" "$tmp/ref"

# selftest <case> <expected text>: problems must report the text.
selftest() {
  out=$(REF="$tmp/ref" problems)
  if printf '%s\n' "$out" | grep -q "$2"; then printf 'ok %s\n' "$1"; else printf 'not ok %s: %s\n' "$1" "$out"; failed=1; fi
}
rm "$tmp/ref/define.md"
selftest page-removed 'no page for skill define'
cp "$REF/define.md" "$tmp/ref/define.md"
grep -v '(close.md)' "$REF/README.md" > "$tmp/ref/README.md"
selftest index-line-removed 'index does not link close.md'

exit $failed
