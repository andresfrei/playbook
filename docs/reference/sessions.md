# sessions

Why sessions are short.

## Why

The context each request carries is what costs. Claude Code's documentation: "Use `/clear` to start fresh when switching to unrelated work"; "Each model has its own cache. Switching with `/model` means the next request reads the entire conversation history with no cache hits"; "Pick your model and effort level at the top of a session."

## What the playbook does

- It cuts a session where the handoff is already written: at the end of a task when the next is a different one, and after a unit, it asks whether to close there. On a yes you type `/clear`, since Claude cannot run built-in commands.
- Choose the model at the start, not mid-way.
- A fresh session beats `--resume`, since "your first message after a break longer than the cache lifetime misses the cache and reprocesses your full context."
- For cheaper searches, copy `extras/Explore.md` to `~/.claude/agents/`: it runs Claude Code's Explore on `haiku`.

## Connects to

- [define](define.md) and [close](close.md), which ask whether to close the session.
- [build-mode](build-mode.md), [rules](rules.md), and [session-start](session-start.md).

Source: the section "Why sessions are short" of [plugins/playbook/README.md](../../plugins/playbook/README.md)
