#!/bin/sh
# PreToolUse: runs only when an "if" filter of hooks.json matched a delivery
# command (push, pull request, merge, release). It always asks (R14).
cat > /dev/null
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"R14: push, pull requests, merges, and releases are the owner'"'"'s decisions. Confirm this one."}}'
