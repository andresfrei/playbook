# capture

The hook `capture` stores each dialog the owner answers, so the plugin can learn from them later (dialog-learning-2).

## When it runs

- At `PostToolUse` of the tool `AskUserQuestion`, after the owner answered.

## What it reads

- The hook's input, as it arrives: the questions, their options, and the answers.

## What it writes

- One line per answered dialog in `dialogs.jsonl`, in the plugin's data folder (`CLAUDE_PLUGIN_DATA`): the UTC time and the input, with raw newlines removed. It parses nothing. With no data folder it writes nothing. It prints nothing and always exits 0, so it never blocks an answer.
- The lines hold the text of questions and answers of every project, and stay on the machine.

## The import

- `sh plugins/playbook/scripts/import-dialogs.sh [PROJECTS_DIR]` fills `dialogs.jsonl` with the dialogs answered before the hook existed. It runs once, by hand.
- It reads every `*.jsonl` under `PROJECTS_DIR` (default `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects`) and takes the lines that are an answered `AskUserQuestion` (a `toolUseResult` with `questions` and `answers`). Anything else is ignored.
- It appends, in time order, one line per dialog in the same file and shape as the hook's, with `"origin":"import"`; a line with no `origin` is from the hook. It skips every `tool_use_id` already in the file, so a second run adds none. It prints how many it imported and how many were already present.
- The transcript format "is internal to Claude Code and changes between versions" (sessions.md). When transcripts exist and none holds an answered dialog, it says so on stderr, writes nothing, and exits 1. It also exits 1 with no transcripts, with no `jq`, or with no `CLAUDE_PLUGIN_DATA`.

## What it asks the owner

- Nothing.

## Connects to

- [ask](ask.md) and [commit-check](commit-check.md), the `PreToolUse` hooks; this is the only `PostToolUse` hook.

Source: [plugins/playbook/hooks/capture.sh](../../plugins/playbook/hooks/capture.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
