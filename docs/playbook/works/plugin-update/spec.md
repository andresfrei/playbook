# Spec of the work plugin-update

Status: Accepted (plugin-update-1).

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (plugin-update-1)

The owner's installed plugin stayed at 5.0.0 while 5.2.0 was released, because auto-update is off for a third-party marketplace and nothing told them. Claude Code already updates and tells the user when auto-update is on, so the playbook only has to say how to turn it on.

Claude Code's documentation, read on 2026-11-22:

- discover-plugins.md: auto-update is "**Off by default**: every other marketplace, including the community marketplace, third-party marketplaces, and local development marketplaces"; "Select the marketplace to open its menu, then turn auto-update on or off"; "When you see `Plugin updated: <name> · Run /reload-plugins to apply`, run `/reload-plugins` in that session."
- plugins/loading.md: "Whether or not you reload, the new versions load on your next launch"; a pinned `version` "keeps every user on the cached copy until its author changes the string", which each release does (TD22).

## What changes

1. The root README's install section says how to turn on auto-update and what Claude Code shows after an update.

## Out of scope

- A notice, hook, or command of the playbook's own.
- The owner's machine, which loads the plugin from a worktree of local `main` (the line in this repository's `CLAUDE.md`).

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Change 1 | The check above | Done |
