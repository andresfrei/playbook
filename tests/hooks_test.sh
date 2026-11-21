#!/bin/sh
# Tests of the hooks of plugins/playbook. Run from the repository root.
# shellcheck disable=SC2015
CLAUDE_PLUGIN_ROOT=$(pwd)/plugins/playbook; export CLAUDE_PLUGIN_ROOT
hooks=$CLAUDE_PLUGIN_ROOT/hooks
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0
ok() { printf 'ok %s\n' "$1"; }
bad() { printf 'not ok %s: %s\n' "$1" "$2"; failed=1; }

# A repository with a valid wiki, committed.
repo=$tmp/repo
mkdir -p "$repo/docs/wiki/works/a"
printf '# W\n' > "$repo/docs/wiki/README.md"
printf '| ID | Date | Decision | Who | Their words |\n|---|---|---|---|---|\n| a-1 | d | x | O | "yes" |\n' > "$repo/docs/wiki/works/a/decisions.md"
git -C "$repo" init -q && git -C "$repo" add -A && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm init

commit() { # commit <cwd> <command>
  printf '{"cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$2" | sh "$hooks/commit-check.sh"
}

out=$(commit "$repo" "git commit -m x")
[ -z "$out" ] && ok "clean wiki: silent" || bad "clean wiki" "$out"

printf '[x](gone.md)\n' >> "$repo/docs/wiki/README.md"
out=$(commit "$repo" "git commit -m x")
case $out in *'"deny"'*gone.md*) ok "broken wiki: deny" ;; *) bad "broken wiki" "$out" ;; esac

out=$(commit "$tmp" "cd repo && git commit -m x")
case $out in *'"deny"'*) ok "cd <dir>: found" ;; *) bad "cd <dir>" "$out" ;; esac

out=$(commit "/" "git -C $repo commit -m x")
case $out in *'"deny"'*) ok "git -C <dir>: found" ;; *) bad "git -C <dir>" "$out" ;; esac

out=$(commit "$tmp" "git commit -m x")
[ -z "$out" ] && ok "not a repository: silent" || bad "not a repository" "$out"

out=$(printf '{}' | sh "$hooks/ask.sh")
case $out in *'"permissionDecision":"ask"'*) ok "ask.sh asks" ;; *) bad "ask.sh" "$out" ;; esac

out=$(CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh" | tail -n 1)
[ "$out" = "Talk to the person in Spanish." ] && ok "session start: language" || bad "session start" "$out"

out=$(CLAUDE_PROJECT_DIR=$repo sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/wiki/README.md'*'# W'*) ok "session start: wiki README" ;; *) bad "session start: wiki README" "missing" ;; esac

out=$(CLAUDE_PROJECT_DIR=$tmp sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/wiki/README.md'*) bad "session start: no wiki" "printed" ;; *) ok "session start: no wiki" ;; esac

# The README and the rules share the 10,000 characters of the hook's output.
budget=$((9000 - $(wc -c < "$CLAUDE_PLUGIN_ROOT/rules.md" | tr -d ' ')))
readme_of() { # readme_of <dir> <characters>
  mkdir -p "$1/docs/wiki"
  awk -v n="$2" 'BEGIN { for (i = 1; i < n; i++) printf "x"; print "" }' > "$1/docs/wiki/README.md"
}
readme_of "$tmp/fits" $((budget - 100))
out=$(CLAUDE_PROJECT_DIR=$tmp/fits sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/wiki/README.md'*) ok "session start: README within the budget" ;; *) bad "session start: README within the budget" "not printed" ;; esac

readme_of "$tmp/big" $((budget + 100))
out=$(CLAUDE_PROJECT_DIR=$tmp/big sh "$hooks/session-start.sh")
case $out in
  *'too long to load with the rules'*) [ $((budget + 100)) -lt 10000 ] && ok "session start: README that fits alone but not with the rules" || bad "session start: README alone" "the case does not fit alone" ;;
  *) bad "session start: README that fits alone but not with the rules" "printed whole" ;;
esac

exit $failed
