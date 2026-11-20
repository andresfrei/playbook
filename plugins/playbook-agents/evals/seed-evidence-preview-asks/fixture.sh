#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
printf "export const app = {};\n" > app.js
git add -A
git commit -q -m "feat: app"
# A review of the repository in the foreground, as a transcript line pair.
review() { # file id time report
  printf "{\"type\":\"assistant\",\"message\":{\"content\":[{\"type\":\"tool_use\",\"id\":\"toolu_%s\",\"name\":\"Agent\",\"input\":{\"description\":\"d\",\"subagent_type\":\"playbook-agents:review\",\"prompt\":\"p\"}}]},\"timestamp\":\"%s\"}\n" "$2" "$3" >> "$1"
  printf "{\"type\":\"user\",\"message\":{\"content\":[{\"tool_use_id\":\"toolu_%s\",\"type\":\"tool_result\",\"content\":\"%s\"}]},\"timestamp\":\"%s\"}\n" "$2" "$4" "$3" >> "$1"
}
name_of() { printf "%s" "$1" | sed "s/[^A-Za-z0-9]/-/g"; }
home=$PWD/.claude-home
dir=$home/projects/$(name_of "$(pwd -P)")
mkdir -p "$dir"
review "$dir/s.jsonl" A1 2026-11-10T10:00:00.000Z '1. The date check accepts 2026-13-45.\\n2. No test covers an empty list.'
review "$dir/s.jsonl" B2 2026-11-11T09:00:00.000Z 'No findings.'
review "$dir/s.jsonl" C3 2026-11-12T08:30:00.000Z '1. A parser drops rows after a blank line.'
