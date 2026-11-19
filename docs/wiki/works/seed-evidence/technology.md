# Technology of the work seed-evidence

What the work needs from its technology, from [definition.md](definition.md).

## Needs

| ID | Need | From | Proposed answer | Status |
|----|------|------|-----------------|--------|
| N1 | Read the transcripts of one repository and print its reviews: date, findings or "No findings.", and the report's text | seed-evidence-1, -3 | A script of `playbook-agents` in POSIX `sh` and `awk`, as its other scripts, reading the JSON lines without a parser: the call to an agent named `review`, its tool result in the foreground, or the result of its task notification in the background. (seed-evidence-7) | Decided |
| N2 | Find the transcripts of the repository | seed-evidence-2 | The folder of `~/.claude/projects/` (or `$CLAUDE_CONFIG_DIR/projects/`) named after the repository's path, plus those named after its worktrees (`git worktree list`) (seed-evidence-8) | Decided |
| N3 | The command | seed-evidence-2, -3, -4, -5 | A skill of `playbook-agents` with `disable-model-invocation: true`, so only the person starts it and it does not count against L4: it runs the script of N1, shows the preview with the count of runs, and on the person's choice starts `classify` once per review, in order (seed-evidence-8) | Decided |
