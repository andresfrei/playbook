#!/bin/sh
# PreToolUse: asks before delivery (R14): a push, a pull request created or
# merged, a release created, edited, deleted, or uploaded to. The "if" filters
# of hooks.json also let through commands that hold $(), backticks, or $VAR,
# so this hook asks only when the command itself delivers. When it cannot read
# the command, such as when awk fails, it asks too (basics-23).
# shellcheck disable=SC1091,SC2034 # lib.sh is sourced at run time and reads $command.
. "${CLAUDE_PLUGIN_ROOT}/hooks/lib.sh"
command=$(field command)
reason='R14: push, pull requests, merges, and releases are the owner'"'"'s decisions. Confirm this one.'
found=1
for words in 'git push' 'gh pr create' 'gh pr merge' 'gh release create' 'gh release edit' \
  'gh release delete' 'gh release delete-asset' 'gh release upload'; do
  # shellcheck disable=SC2086 # the words are separate arguments.
  has $words
  found=$?
  [ "$found" -eq 1 ] || break
done
[ "$found" -eq 1 ] && exit 0
[ "$found" -eq 0 ] || reason='R14: the hook could not read this command. Confirm that it does not push, open or merge a pull request, or publish a release.'
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
