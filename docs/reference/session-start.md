# session-start

The hook `session-start` loads the playbook's rules, and the project's wiki README when there is one, into the start of every session.

## When it runs

- At `SessionStart`, in every session. [adopt](adopt.md) runs after it.

## What it reads

- `rules.md` of the plugin, see [rules](rules.md).
- `docs/playbook/README.md` at the root of the git repository, also when the session starts in a subfolder; without a git repository, the session's folder.
- The plugin option `language`, and the record `language-asked` in the plugin's data folder.

## What it writes

- It prints to the session's context, in this order:
  1. The language. When the option `language` is set, a line telling Claude to reply in it. When the option is empty and no `language-asked` record exists, a line telling Claude to ask the person once, with `AskUserQuestion`, which language to reply in, and to point them to the playbook row of `/config` to save it; the hook then creates the record. Without a plugin data folder nothing is asked.
  2. The rules.
  3. The wiki README, headed "The wiki: docs/playbook/README.md". The rules and the README must fit together in 9,000 characters, under the 10,000-character cap of hook output; when the README is too long, the hook prints a line asking Claude to read it first and shorten it instead.
  4. Again the line to talk in the chosen language, when the option is set.
- It writes no project file. The only file it creates is the `language-asked` record.

## What it asks the owner

- Nothing itself. When the language is not set and not yet asked, it tells Claude to ask once.

## Connects to

- [rules](rules.md) and [wiki](wiki.md), the content it loads.
- [adopt](adopt.md), the other `SessionStart` hook.
- [sessions](sessions.md), on why the start is kept small.
- [audit](audit.md), whose setup part measures the same 9,000-character budget with `startup-context.sh`.

Source: [plugins/playbook/hooks/session-start.sh](../../plugins/playbook/hooks/session-start.sh), wired in [hooks.json](../../plugins/playbook/hooks/hooks.json)
