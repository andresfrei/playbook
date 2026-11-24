# builder

The agent `builder` builds one unit of an accepted spec from a brief. It runs on `sonnet`.

## When it runs

- When the line `Build mode: builder` is set, the main session writes a brief and runs it to build a unit, while the main session keeps defining and verifying. When two or more pending units change different files and none uses what another builds, one `builder` per unit may run at the same time, on the owner's yes.
- Its tools are Read, Glob, Grep, Edit, Write, and Bash.

## What it reads

- The brief: the spec, the unit, the files to read, and the check; it may also name the paths the agent may change.
- The spec, the unit's row, and the files the brief names, then what it needs around them.

## What it writes

- Only that unit's work, with its tests when the behaviour changes. When the brief names the paths it may change, it changes only those, by an edit or by a command it runs.
- It does not change the spec, the wiki, or another unit, and it does not commit. When the unit needs another path, such as a lockfile or a generated file, it stops and reports it. It does not undo a change it did not make.
- It runs the check the brief names, and only that one; when the check fails on a path that is not its own, it reports the failure and does not fix it.

## What it asks the owner

- Nothing. It reports in a few lines: the files changed, the check's command and result, and anything the spec leaves open. It reports no result it did not run.

## Connects to

- [build-mode](build-mode.md), which sets when it runs, and [define](define.md), which writes the spec and units it builds.
- [close](close.md), which checks the build, and [reviewer](reviewer.md), which reads a risky change.
- [rules](rules.md) and [sessions](sessions.md).

Source: [plugins/playbook/agents/builder.md](../../plugins/playbook/agents/builder.md)
