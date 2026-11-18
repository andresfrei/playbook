#!/bin/bash
# Runs /code-review with the review rule in CLAUDE.md on the seeded diff of a
# case, isolated from the owner's configuration (review-evidence-10): the diff
# is built under TMPDIR, outside the home folder, and claude runs with an empty
# CLAUDE_CONFIG_DIR, so none of the owner's plugins, hooks, memory, or global
# CLAUDE.md loads. Each run writes its stream-json output, whose first event,
# init, lists what the session loaded, and whose last, result, holds its cost.
# Usage: CLAUDE_CODE_OAUTH_TOKEN=... bash run-rule.sh <case folder> <runs> <out folder> [budget USD]
set -eu
case_dir=$(cd "$1" && pwd)
runs=$2
out=$3
budget=${4:-2}
: "${CLAUDE_CODE_OAUTH_TOKEN:?set CLAUDE_CODE_OAUTH_TOKEN from claude setup-token}"
mkdir -p "$out"
out=$(cd "$out" && pwd)
name=$(basename "$case_dir")
for i in $(seq 1 "$runs"); do
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/review-evidence.XXXXXX")
  mkdir "$tmp/config" "$tmp/ws"
  (cd "$tmp/ws" && bash "$case_dir/fixture.sh" --rule)
  (cd "$tmp/ws" && CLAUDE_CONFIG_DIR="$tmp/config" claude -p "/code-review high HEAD~1..HEAD" \
    --model opus --output-format stream-json --verbose --no-session-persistence \
    --allowedTools "Read Grep Glob Skill Bash(git diff:*) Bash(git log:*) Bash(git show:*)" \
    --max-budget-usd "$budget" > "$out/$name-rule-$i.jsonl" 2> "$out/$name-rule-$i.err") || true
  rm -rf "$tmp"
done
