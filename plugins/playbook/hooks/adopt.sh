#!/bin/sh
# SessionStart: inside a git repository, recommends /playbook:audit-wiki while the
# project has no playbook wiki, or its wiki has no line "Last audit:". The
# message goes out as a systemMessage, which the person sees, and as context
# for Claude. Outside a git repository it prints nothing.
dir=${CLAUDE_PROJECT_DIR:-.}
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
readme=$root/docs/playbook/README.md
if [ ! -f "$readme" ]; then
  message='No playbook wiki: run /playbook:audit-wiki to adopt this project, or /playbook:define to start a new one.'
elif ! grep -q '^Last audit:' "$readme"; then
  message='This playbook wiki has no audit yet: run /playbook:audit-wiki.'
else
  exit 0
fi
printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$message" "$message"
