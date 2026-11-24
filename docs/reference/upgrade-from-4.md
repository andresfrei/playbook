# upgrade-from-4

How to move from version 4.x to 5.

## What changed

Version 5 replaces the three plugins with one and moves the wiki to `docs/playbook/`.

## Steps

Uninstall the old plugins and update `playbook`:

```sh
claude plugin uninstall playbook-agents@playbook
claude plugin uninstall playbook-wiki@playbook
claude plugin marketplace update playbook
claude plugin update playbook@playbook
```

If `/playbook:init` turned them on for one repository only, run the two `uninstall` lines from that repository with `--scope local`.

Then run [audit](audit.md) in each project. It moves the 4.x wiki in `docs/wiki/` into `docs/playbook/`, keeping every decision and the owner's words; the check reads those decisions in their 4.x format.

## Connects to

- [audit](audit.md), which does the move, and [wiki](wiki.md), the new layout.
- [adopt](adopt.md), which recommends the audit in a project not yet adopted.

Source: the section "From 4.x" of the [README](../../README.md)
