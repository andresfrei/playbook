#!/bin/sh
# Tests of the hooks of plugins/playbook. Run from the repository root.
# shellcheck disable=SC2015,SC2016
CLAUDE_PLUGIN_ROOT=$(pwd)/plugins/playbook; export CLAUDE_PLUGIN_ROOT
hooks=$CLAUDE_PLUGIN_ROOT/hooks
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0
ok() { printf 'ok %s\n' "$1"; }
bad() { printf 'not ok %s: %s\n' "$1" "$2"; failed=1; }

# A repository with a valid wiki, committed.
repo=$tmp/repo
mkdir -p "$repo/docs/playbook/works/a"
printf '# W\n' > "$repo/docs/playbook/README.md"
printf '| ID | Date | Decision | Who | Their words |\n|---|---|---|---|---|\n| a-1 | d | x | O | "yes" |\n' > "$repo/docs/playbook/works/a/decisions.md"
git -C "$repo" init -q && git -C "$repo" add -A && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm init

commit() { # commit <cwd> <command>
  printf '{"cwd":"%s","tool_input":{"command":"%s"}}' "$1" "$2" | sh "$hooks/commit-check.sh"
}

out=$(commit "$repo" "git commit -m x")
[ -z "$out" ] && ok "clean wiki: silent" || bad "clean wiki" "$out"

printf '[x](gone.md)\n' >> "$repo/docs/playbook/README.md"
out=$(commit "$repo" "git commit -m x")
case $out in *'"deny"'*gone.md*) ok "broken wiki: deny" ;; *) bad "broken wiki" "$out" ;; esac

out=$(commit "$tmp" "cd repo && git commit -m x")
case $out in *'"deny"'*) ok "cd <dir>: found" ;; *) bad "cd <dir>" "$out" ;; esac

out=$(commit "/" "git -C $repo commit -m x")
case $out in *'"deny"'*) ok "git -C <dir>: found" ;; *) bad "git -C <dir>" "$out" ;; esac

out=$(commit "$repo" "git -C $repo commit -m \\\"fix: push\\\"")
case $out in *'"deny"'*) ok "broken wiki, commit message naming push: deny" ;; *) bad "commit message naming push" "$out" ;; esac

# A quoted folder, as Claude often writes it, and a folder with a space.
cp -R "$repo" "$tmp/my repo"
for c in "cd 'repo' && git commit -m x" "cd '$repo' && git commit -m x" 'cd \"repo\" && git commit -m x' \
  "cd 'my repo' && git commit -m x" 'cd my\\ repo && git commit -m x' "git -C 'my repo' commit -m x" \
  "cd '$tmp' && git -C 'my repo' commit -m x"; do
  case $(commit "$tmp" "$c") in *'"deny"'*) ok "broken wiki: $c" ;; *) bad "broken wiki: $c" "no deny" ;; esac
done

# A value with a quote inside it, and a folder the hook cannot resolve.
for c in "git -c user.name='Andres Frei' commit -m x" "sh -c 'git add -A && git commit -m x'" \
  "# Don't stage the lockfile\\ngit add src && git commit -m x\\n# now it's safe" 'git -C \"$(git rev-parse --show-toplevel)\" commit -m x' \
  'git -C \"$root\"/. commit -m x'; do
  case $(commit "$repo" "$c") in *'"deny"'*) ok "broken wiki: $c" ;; *) bad "broken wiki: $c" "no deny" ;; esac
done

out=$(commit "$repo" 'for f in $(ls); do cat $f; done')
[ -z "$out" ] && ok "broken wiki, not a commit: silent" || bad "broken wiki, not a commit" "$out"

out=$(commit "$tmp" "git commit -m x")
[ -z "$out" ] && ok "not a repository: silent" || bad "not a repository" "$out"

# ask.sh asks only for a command that delivers. The "if" filters also let
# through any command with $(), backticks, or $VAR.
ask() { printf '{"tool_input":{"command":"%s"}}' "$1" | sh "$hooks/ask.sh"; }
for c in 'git push origin main' 'cd x && git push' 'git -C ../a push -u origin b' 'gh pr create --fill' \
  'gh -R o/r pr merge 3' 'gh release create v1' 'echo hi\ngit push' 'gh release upload v1 a.tgz' \
  'timeout 120 git push origin main' 'timeout -s KILL 5m git push' 'nohup git push' 'nice -n 10 git push' \
  'stdbuf -oL git push' 'command git push' 'echo main | xargs git push origin' 'git --no-pager push' \
  'git -c push.default=current push' 'FOO=1 git push' 'if git push; then echo ok; fi' \
  "git -C 'my repo' push" 'git -C \"my own repo\" push origin main' 'git -C my\\ repo push' "gh -R 'o/r' pr merge 3"; do
  case $(ask "$c") in *'"permissionDecision":"ask"'*) ok "ask: $c" ;; *) bad "ask: $c" "did not ask" ;; esac
done
for c in 'for f in $(ls); do cat $f; done' 'git status --porcelain' 'echo git push' 'gh release view v1' \
  'cat "$f" | grep push' 'git log -n 3' 'git stash push -u -m wip' 'git commit -m \"fix: ask before push\"' \
  'command -v git' 'gh issue create --title \"pr create\"' 'git log --grep push' "git -C 'my repo' stash push"; do
  out=$(ask "$c")
  [ -z "$out" ] && ok "silent: $c" || bad "silent: $c" "$out"
done

# Quotes, substitutions, and heredocs; one command a line, escaped as JSON.
while IFS= read -r c; do
  case $(ask "$c") in *'"permissionDecision":"ask"'*) ok "ask: $c" ;; *) bad "ask: $c" "did not ask" ;; esac
done <<'CASES'
git -C \"$repo\"/sub push origin main
gh -R \"$owner\"/repo pr merge 3
git -C 'R&D docs' push
git -C 'my repo (old)' push
git -C 'my repo ' push
git -c http.extraheader=\"AUTHORIZATION: basic x\" push
git --git-dir='my repo/.git' push
GIT_SSH_COMMAND='ssh -i key' git push
git -C \"$(pwd)\" push
git -C \"$(git rev-parse --show-toplevel)\" push -u origin b
echo \"$(git push)\"
echo `git push`
{ git push; }
(cd x && git push)
git \\\n  push origin main
git commit -m \"$(cat <<'EOF'\ndon't stop (yet\nEOF\n)\" && git push
cat <<EOF > notes.txt\nit's here\nEOF\ngit push
git commit -m \"it's done && git push
bash -c \"cd repo && git push origin main\"
sh -c 'git add -A && git commit -m x && git push'
bash -lc 'eval \"gh pr merge 3 --squash\"'
env GIT_TERMINAL_PROMPT=0 git push origin main
env -u GIT_DIR git push
sudo -u deploy git push
git tag -l 'v*' | xargs -n 1 git push origin
git branch --format='%(refname:short)' | xargs -I{} git push origin {}
bash <<'EOF'\ncd repo\ngit push\nEOF
ssh host bash -s <<EOF\ngit push origin main\nEOF
# Let's ship it\ngit push origin main\n# that's all
/usr/bin/git push
git push>/dev/null
git push 2>&1 | tail -3
timeout \"$T\" git push
time -p git push
command -p git push
CASES
while IFS= read -r c; do
  out=$(ask "$c")
  [ -z "$out" ] && ok "silent: $c" || bad "silent: $c" "$out"
done <<'CASES'
git commit -m \"x; git push\"
git commit -m 'docs: git push asks'
echo \"git push\"
git -c user.name='Andres Frei' commit -m x
cat <<EOF\ngit push\nEOF
git commit -m \"$(cat <<'EOF'\nfix: ask before git push\n\ngh pr create is asked too\nEOF\n)\"
git -C 'my repo' log --grep \"gh pr merge\"
bash -c \"echo git push\"
ls # git push
# git push\nls
env | grep GIT
sudo -u deploy git status
CASES

# When the hook cannot read the command, it asks; and a hook that fails blocks.
mkdir -p "$tmp/noawk"
printf '#!/bin/sh\nexit 2\n' > "$tmp/noawk/awk"
chmod +x "$tmp/noawk/awk"
out=$(printf '{"tool_input":{"command":"ls"}}' | PATH="$tmp/noawk:$PATH" sh "$hooks/ask.sh" 2>/dev/null)
case $out in *'"permissionDecision":"ask"'*'could not read'*) ok "ask: awk fails" ;; *) bad "ask: awk fails" "$out" ;; esac
[ "$(grep -c 'ask.sh' "$hooks/hooks.json")" = "$(grep -c '"onFailure": "block"' "$hooks/hooks.json")" ] &&
  ok "hooks.json: each ask.sh entry blocks on failure" || bad "hooks.json" "an ask.sh entry without onFailure"

unset CLAUDE_PLUGIN_DATA CLAUDE_PLUGIN_OPTION_LANGUAGE PLAYBOOK_DRIVEN_BY
data=$tmp/plugin-data
out=$(CLAUDE_PLUGIN_DATA=$data sh "$hooks/session-start.sh")
case $out in *'ask the person with AskUserQuestion'*'/config'*) ok "session start: asks the language" ;; *) bad "session start: asks the language" "$out" ;; esac
[ -f "$data/language-asked" ] && ok "session start: record created" || bad "session start: record created" "missing"
out=$(CLAUDE_PLUGIN_DATA=$data sh "$hooks/session-start.sh")
case $out in *'ask the person with AskUserQuestion'*|*'Reply to the person'*|*'Talk to the person'*) bad "session start: asked once" "$out" ;; *) ok "session start: asked once" ;; esac
out=$(CLAUDE_PLUGIN_DATA=$tmp/data2 CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh")
case $out in *'ask the person with AskUserQuestion'*) bad "session start: option set, no question" "$out" ;; *'Reply to the person in Spanish'*'Talk to the person in Spanish.'*) ok "session start: option set, no question" ;; *) bad "session start: option set" "$out" ;; esac
[ ! -e "$tmp/data2" ] && ok "session start: option set, no record" || bad "session start: option set, no record" "created"
out=$(CLAUDE_PLUGIN_DATA='' sh "$hooks/session-start.sh")
case $out in *'ask the person with AskUserQuestion'*) bad "session start: no data dir, silent" "$out" ;; *) ok "session start: no data dir, silent" ;; esac

# Driven mode: PLAYBOOK_DRIVEN_BY marks a session no person answers.
rm -rf "$tmp/ddata"
out=$(PLAYBOOK_DRIVEN_BY=playbot CLAUDE_PLUGIN_DATA=$tmp/ddata sh "$hooks/session-start.sh")
case $out in *'This session is driven: no person is at its terminal, and the session `playbot` answers for the owner. Where a rule or a skill says to ask, or to ask with `AskUserQuestion`, write the question in text instead, with its type first (one of the words of R3, as `Scope: ...`) and its options with the recommended one first. Send it with SendMessage to `playbot`, one question per message, naming the project and the step, then end your turn and wait. A reply from `playbot` is the owner'"'"'s answer. Open no dialog, and do not ask to close or clear the session. Do not write outside the project'"'"'s folder, such as a line for `~/.claude/CLAUDE.md`, a user setting, or a preset: send it to `playbot` as a proposal.'*) ok "driven: the block with the name" ;; *) bad "driven: the block with the name" "$out" ;; esac
case $out in *'(ask-to-clear-2)'*) bad "driven: no ask-to-clear line" "printed" ;; *) ok "driven: no ask-to-clear line" ;; esac
case $out in *'ask the person with AskUserQuestion'*) bad "driven: no language question" "$out" ;; *) ok "driven: no language question" ;; esac
[ ! -e "$tmp/ddata" ] && ok "driven: no language-asked record" || bad "driven: no language-asked record" "created"
out=$(PLAYBOOK_DRIVEN_BY=playbot CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh")
case $out in 'Reply to the person in Spanish'*'Talk to the person in Spanish.') ok "driven: language lines still print" ;; *) bad "driven: language lines" "$out" ;; esac
out=$(PLAYBOOK_DRIVEN_BY='' CLAUDE_PLUGIN_DATA=$tmp/ddata2 sh "$hooks/session-start.sh")
person=$(CLAUDE_PLUGIN_DATA=$tmp/ddata3 sh "$hooks/session-start.sh")
[ "$out" = "$person" ] && ok "driven: empty variable, same as a person" || bad "driven: empty variable" "differs"
long=$(awk 'BEGIN { for (i = 0; i < 201; i++) printf "x" }')
nl='a
b'
for v in 'a"b' "$nl" "$long"; do
  out=$(PLAYBOOK_DRIVEN_BY=$v CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh")
  case $out in
    *'PLAYBOOK_DRIVEN_BY was ignored'*'(ask-to-clear-2)'*) case $out in *'This session is driven'*) bad "driven: invalid value" "block printed" ;; *) ok "driven: invalid value ignored" ;; esac ;;
    *) bad "driven: invalid value ignored" "$out" ;;
  esac
done
name200=$(awk 'BEGIN { for (i = 0; i < 200; i++) printf "x" }')
out=$(PLAYBOOK_DRIVEN_BY=$name200 sh "$hooks/session-start.sh" | grep -c 'This session is driven')
[ "$out" = 1 ] && ok "driven: a 200-character name is used" || bad "driven: 200 characters" "$out"
# rules (filtered) + this repository's README + the block stay under 9,000, with the README loaded.
out=$(PLAYBOOK_DRIVEN_BY=playbot CLAUDE_PROJECT_DIR=$PWD CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh")
total=$(printf '%s\n' "$out" | wc -c | tr -d ' ')
case $out in *'# The wiki: docs/playbook/README.md'*) [ "$total" -lt 9000 ] && ok "driven: rules, README, and block under 9,000 ($total)" || bad "driven: budget" "$total" ;; *) bad "driven: README loaded with the block" "$total" ;; esac

out=$(CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh" | tail -n 1)
[ "$out" = "Talk to the person in Spanish." ] && ok "session start: language" || bad "session start" "$out"

out=$(CLAUDE_PLUGIN_OPTION_LANGUAGE=Spanish sh "$hooks/session-start.sh" | head -n 1)
case $out in 'Reply to the person in Spanish, in every message.'*) ok "session start: language first" ;; *) bad "session start: language first" "$out" ;; esac

out=$(CLAUDE_PROJECT_DIR=$repo sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/playbook/README.md'*'# W'*) ok "session start: wiki README" ;; *) bad "session start: wiki README" "missing" ;; esac

out=$(CLAUDE_PROJECT_DIR=$tmp sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/playbook/README.md'*) bad "session start: no wiki" "printed" ;; *) ok "session start: no wiki" ;; esac

# The README and the rules share the 10,000 characters of the hook's output.
budget=$((9000 - $(wc -c < "$CLAUDE_PLUGIN_ROOT/rules.md" | tr -d ' ')))
readme_of() { # readme_of <dir> <characters>
  mkdir -p "$1/docs/playbook"
  awk -v n="$2" 'BEGIN { for (i = 1; i < n; i++) printf "x"; print "" }' > "$1/docs/playbook/README.md"
}
readme_of "$tmp/fits" $((budget - 100))
out=$(CLAUDE_PROJECT_DIR=$tmp/fits sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/playbook/README.md'*) ok "session start: README within the budget" ;; *) bad "session start: README within the budget" "not printed" ;; esac

readme_of "$tmp/big" $((budget + 100))
out=$(CLAUDE_PROJECT_DIR=$tmp/big sh "$hooks/session-start.sh")
case $out in
  *'too long to load with the rules'*) [ $((budget + 100)) -lt 10000 ] && ok "session start: README that fits alone but not with the rules" || bad "session start: README alone" "the case does not fit alone" ;;
  *) bad "session start: README that fits alone but not with the rules" "printed whole" ;;
esac

# A session started in a folder of the repository finds the wiki at its root.
mkdir -p "$repo/packages/x"
out=$(CLAUDE_PROJECT_DIR=$repo/packages/x sh "$hooks/session-start.sh")
case $out in *'# The wiki: docs/playbook/README.md'*) ok "session start: from a subfolder" ;; *) bad "session start: from a subfolder" "missing" ;; esac

# Adoption: a systemMessage inside a git repository not yet adopted.
adopt() { CLAUDE_PROJECT_DIR=$1 sh "$hooks/adopt.sh"; }
mkdir -p "$tmp/bare" && git -C "$tmp/bare" init -q
out=$(adopt "$tmp/bare")
case $out in *'"systemMessage":"No playbook wiki: run /playbook:audit'*) ok "adopt: no wiki" ;; *) bad "adopt: no wiki" "$out" ;; esac

out=$(adopt "$repo")
case $out in *'"systemMessage":"This playbook wiki has no audit yet'*) ok "adopt: no audit yet" ;; *) bad "adopt: no audit yet" "$out" ;; esac

mkdir -p "$tmp/done/docs/playbook" && git -C "$tmp/done" init -q
printf '# W\n\nLast audit: 2026-11-21, after work a. Contradictions: 0, 0.\n' > "$tmp/done/docs/playbook/README.md"
out=$(adopt "$tmp/done")
[ -z "$out" ] && ok "adopt: audited, silent" || bad "adopt: audited" "$out"

mkdir -p "$tmp/done/sub"
out=$(adopt "$tmp/done/sub")
[ -z "$out" ] && ok "adopt: audited, from a subfolder, silent" || bad "adopt: from a subfolder" "$out"

mkdir -p "$tmp/nogit"
out=$(adopt "$tmp/nogit")
[ -z "$out" ] && ok "adopt: not a repository, silent" || bad "adopt: not a repository" "$out"

# capture: one line per answered dialog in the data folder.
fixture='{"session_id":"s","cwd":"/x","hook_event_name":"PostToolUse","tool_name":"AskUserQuestion","tool_input":{"questions":[{"question":"Q?","header":"Session","options":[{"label":"Sí"},{"label":"No"}]}]},"tool_response":{"answers":{"Q?":"Sí"}}}'
pretty='{
  "session_id": "s",
  "tool_name": "AskUserQuestion",
  "tool_response": {
    "answers": {"Q?": "Sí"}
  }
}'
data=$tmp/data
out=$(printf '%s' "$fixture" | CLAUDE_PLUGIN_DATA=$data sh "$hooks/capture.sh"); rc=$?
[ -z "$out" ] && [ "$rc" -eq 0 ] && ok "capture: silent, exit 0" || bad "capture: silent" "$rc $out"
[ "$(wc -l < "$data/dialogs.jsonl")" -eq 1 ] && ok "capture: one line" || bad "capture: one line" "$(cat "$data/dialogs.jsonl")"
line=$(cat "$data/dialogs.jsonl")
case $line in '{"time":"'[0-9][0-9][0-9][0-9]-*Z'","input":'"$fixture"'}') ok "capture: time and input" ;; *) bad "capture: time and input" "$line" ;; esac
printf '%s' "$pretty" | CLAUDE_PLUGIN_DATA=$data sh "$hooks/capture.sh"; rc=$?
[ "$rc" -eq 0 ] && [ "$(wc -l < "$data/dialogs.jsonl")" -eq 2 ] && ok "capture: two runs, two lines, multi-line input" || bad "capture: two runs" "$rc"
printf '%s' "$pretty" | CLAUDE_PLUGIN_DATA='' sh "$hooks/capture.sh"; rc=$?
[ "$rc" -eq 0 ] && [ "$(wc -l < "$data/dialogs.jsonl")" -eq 2 ] && ok "capture: empty data folder variable, nothing written" || bad "capture: empty variable" "$rc"
(cd "$tmp" && printf '%s' "$fixture" | env -u CLAUDE_PLUGIN_DATA sh "$hooks/capture.sh"); rc=$?
[ "$rc" -eq 0 ] && [ ! -e "$tmp/dialogs.jsonl" ] && ok "capture: no data folder, nothing written" || bad "capture: no data folder" "$rc"
printf 'x' > "$tmp/afile"
out=$(printf '%s' "$fixture" | CLAUDE_PLUGIN_DATA=$tmp/afile/sub sh "$hooks/capture.sh" 2>&1); rc=$?
[ "$rc" -eq 0 ] && [ -z "$out" ] && ok "capture: unwritable folder, exit 0" || bad "capture: unwritable folder" "$rc $out"

exit $failed
