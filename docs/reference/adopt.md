# adopt

The hook `adopt` recommends `/playbook:audit` in a project that is not yet adopted.

## When it runs

- At `SessionStart`, after [session-start](session-start.md).
- Inside a git repository only; outside one it prints nothing.

## What it reads

- `docs/playbook/README.md` at the root of the git repository, for its existence and for a line starting with `Last audit:`.

## What it writes

- Nothing to disk. When the project has no wiki, it prints a message recommending [audit](audit.md) to adopt the project, or [define](define.md) to start a new one. When the wiki has no line `Last audit:`, it prints a message recommending [audit](audit.md). Otherwise it prints nothing.
- The message goes out as a system message the person sees, and as context for Claude.

## What it asks the owner

- Nothing. It only recommends.

## Connects to

- [audit](audit.md) and [define](define.md), the skills it recommends.
- [session-start](session-start.md) and [wiki](wiki.md).

Source: [plugins/playbook/hooks/adopt.sh](../../plugins/playbook/hooks/adopt.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
