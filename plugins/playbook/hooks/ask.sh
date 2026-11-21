#!/bin/sh
# PreToolUse: asks before delivery (R14): a push, a pull request created or
# merged, a release created, edited, deleted, or uploaded to. The "if" filters
# of hooks.json also let through commands that hold $(), backticks, or $VAR,
# so this hook asks only when the command itself delivers.
# shellcheck disable=SC1091,SC2034 # lib.sh is sourced at run time and reads $command.
. "${CLAUDE_PLUGIN_ROOT}/hooks/lib.sh"
command=$(field command)
has git push || has gh pr create || has gh pr merge ||
  has gh release create || has gh release edit || has gh release delete ||
  has gh release delete-asset || has gh release upload || exit 0
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"R14: push, pull requests, merges, and releases are the owner'"'"'s decisions. Confirm this one."}}'
