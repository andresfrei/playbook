# capture

The hook `capture` stores each dialog the owner answers, so the plugin can learn from them later (dialog-learning-2).

## When it runs

- At `PostToolUse` of the tool `AskUserQuestion`, after the owner answered.

## What it reads

- The hook's input, as it arrives: the questions, their options, and the answers.

## What it writes

- One line per answered dialog in `dialogs.jsonl`, in the plugin's data folder (`CLAUDE_PLUGIN_DATA`): the UTC time and the input, with raw newlines removed. It parses nothing. With no data folder it writes nothing. It prints nothing and always exits 0, so it never blocks an answer.
- The lines hold the text of questions and answers of every project, and stay on the machine.

## What it asks the owner

- Nothing.

## Connects to

- [ask](ask.md) and [commit-check](commit-check.md), the `PreToolUse` hooks; this is the only `PostToolUse` hook.

Source: [plugins/playbook/hooks/capture.sh](../../plugins/playbook/hooks/capture.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
