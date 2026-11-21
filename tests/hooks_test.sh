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

exit $failed
