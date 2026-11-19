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
dir=$home/projects/$(name_of /tmp/seed-evidence-old-place)
mkdir -p "$dir"
review "$dir/s.jsonl" D4 2026-11-05T10:00:00.000Z '1. A retry loop never stops on a permanent error.'
