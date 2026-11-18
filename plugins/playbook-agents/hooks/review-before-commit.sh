#!/bin/sh
# PreToolUse hook for Bash commands that run "git commit" (review-trigger-4,
# review-trigger-6). When the agent review has not run since the last commit of
# the session, it holds the call once: it denies it with R20 and what the
# commit changes, so the agent has review read the change or, when the change
# is not risky, runs the same commit again. The same command on the same HEAD
# then runs. A mark left by review-ran.sh lets commits run until HEAD moves.
# Nothing is used up before HEAD moves, since a commit can still fail after
# this hook lets it through.
# Uses only sh, sed, awk, tr, and git. Prints nothing and exits 0 in every other
# case, and when it cannot parse its input, a file is missing, or
# CLAUDE_PLUGIN_DATA is unset: it never blocks a commit by its own error.
plugin="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)" || exit 0
lib="$plugin/hooks/hook-lib.sh"
data=${CLAUDE_PLUGIN_DATA:-}
[ -f "$lib" ] && [ -n "$data" ] || exit 0

# input is read by json_string, in the sourced file.
# shellcheck disable=SC2034
input=$(cat)
# shellcheck source=/dev/null
. "$lib"

command=$(json_string command)
[ -n "$command" ] || exit 0
cwd=$(json_string cwd)
[ -n "$cwd" ] || cwd=.
session=$(json_string session_id)
case $session in '' | *[!A-Za-z0-9_-]*) exit 0 ;; esac

parsed=$(commit_dir)
dir=$(printf '%s\n' "$parsed" | sed -n 1p)
alone=$(printf '%s\n' "$parsed" | sed -n 2p)
[ -n "$dir" ] || exit 0
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$root" ] || exit 0

# A commit that changes only the wiki runs (review-trigger-14): it is not code,
# and playbook-wiki checks it before the commit. Every path that differs from
# the last commit, staged or not, new files included, must be under docs/wiki/;
# a rename or copy counts both its paths. Only when nothing but "cd" and
# "git add" runs before the commit in the same call: anything else could change
# code after this reading.
changed=$(git -C "$root" status --porcelain --untracked-files=all 2>/dev/null)
if [ "$alone" = alone ] && [ -n "$changed" ] && printf '%s\n' "$changed" | awk '
  { p = substr($0, 4)
    if (substr($0, 1, 2) ~ /[RC]/) n = split(p, part, / -> /); else { n = 1; part[1] = p }
    for (i = 1; i <= n; i++) {
      q = part[i]
      if (q ~ /^"/) { sub(/^"/, "", q); sub(/"$/, "", q) }
      if (q !~ /^docs\/wiki\//) bad = 1
    } }
  END { exit bad }'; then
  exit 0
fi

# A repository with no commit yet has no HEAD; the keys still hold the root.
head=$(git -C "$root" rev-parse -q --verify HEAD 2>/dev/null)
here=$(printf '%s\n%s' "$root" "$head")

# The mark is empty when review-ran.sh writes it. The first commit it lets
# through writes the repository and HEAD into it; once HEAD moves, a commit
# has happened and the mark is used up.
mark="$data/review/$session"
if [ -f "$mark" ]; then
  seen=$(cat "$mark" 2>/dev/null)
  if [ -z "$seen" ]; then
    printf '%s' "$here" > "$mark" 2>/dev/null
    exit 0
  fi
  [ "$seen" = "$here" ] && exit 0
  rm -f "$mark"
fi

# A held commit runs on every later try while the command and HEAD are the same.
held="$data/held/$session"
key=$(printf '%s\n%s' "$here" "$command")
[ -f "$held" ] && [ "$(cat "$held" 2>/dev/null)" = "$key" ] && exit 0
mkdir -p "$data/held" 2>/dev/null && printf '%s' "$key" > "$held" 2>/dev/null || exit 0

r20=$(sed -n 's/^- \(R20\. .*\)$/\1/p' "$plugin/rules.md" 2>/dev/null)
[ -n "$r20" ] || r20="R20. A change is risky when a mistake is hard to notice or undo. Have the review agent read it before delivery."
changes=$(git -C "$root" status --short 2>/dev/null | head -n 20)
[ -n "$changes" ] || changes="(nothing differs from the last commit)"

text=$(json_lines "This commit is held once: the agent review has not run since the last commit of this session.
$r20
What the commit changes (git status --short, at most 20 lines):
$changes
If the change is risky by R20, have the review agent read it, then commit again. If it is not, run the same commit again and it will go through.")
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$text"
