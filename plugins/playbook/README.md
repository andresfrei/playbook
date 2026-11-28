# playbook

A Claude Code plugin that helps you build software fast: it defines each change with you before code, records your decisions in your words, and learns from its own mistakes.

```sh
claude plugin marketplace add andresfrei/playbook
claude plugin install playbook@playbook
```

Each piece is described in the [reference](../../docs/reference/README.md).

## Driven sessions

A launcher that drives a session, with no person at its terminal, marks it with `PLAYBOOK_DRIVEN_BY=<session name>`, in its environment or in the `env` of a settings file passed with `--settings`. The session then asks its questions in text, sent to that session with SendMessage, and opens no dialog. Without the variable nothing changes.

## Data it keeps

The plugin keeps one line per answered dialog, with the question and answer text of every project, in `~/.claude/plugins/data/<id>/dialogs.jsonl` on your machine, never in a repository. `claude plugin uninstall` deletes that folder unless you pass `--keep-data`.
