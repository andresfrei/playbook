# close

The skill `/playbook:close` closes a work, or a unit of it, once it is built: it checks the build against the spec, has a risky change read, proposes lines for repeated mistakes, and updates the wiki.

## When it runs

- The owner says a work, or a unit of it, is built and asks to close it, finish it, or check it before delivery.
- It is not used for a small change with no work: run its tests and commit.

## What it reads

- The work's `spec.md`, including its line `Delivery:`, and the check it names.
- For a risky change (stored data, security, an interface others use, concurrency, delivery, untested code), the diff, which it writes to a file for [reviewer](reviewer.md).
- The mistakes and corrections of the work, and its `decisions.md`.
- `docs/playbook/README.md` (the line "Last audit") and `docs/playbook/technology.md` (the line `Versioning:`).

## What it writes

- Fixes for each reviewer finding that breaks the spec or a recorded decision.
- Each line the owner accepts: in the project's `CLAUDE.md`, in `.claude/rules/<topic>.md` with `paths:`, or in a skill's gotchas.
- For a unit: the unit marked done in `spec.md`, and the next unit in the line "Open work" of `docs/playbook/README.md`.
- For the whole work: what it decided, written into the shared pages (`product.md`, `technology.md`, `skills.md`, `design.md`) with each statement citing its decision; the open work cleared; "Replaced by <ID>" on each replaced decision, with the shared pages' citations moved to the new one.
- It runs the [wiki](wiki.md) check and fixes what it lists.

## What it asks the owner

- One question at a time, with a recommendation.
- Each proposed line for the project's rules, accepted or not.
- Each contradiction it finds between a shared page and the decisions.
- After a unit, whether to close the session here and continue in a clean one.
- For a whole work: whether to run [audit](audit.md) (when works closed since the last audit, there is none, or it found a contradiction), whether to run [audit-learning](audit-learning.md), and whether the work needs a new version, which it recommends as MAJOR, MINOR, or PATCH with the number. It recommends none when `Versioning:` says never. On a yes it runs [release](release.md).
- Push, pull requests, merges, and releases remain the owner's decisions.

## Connects to

- [define](define.md), which writes the spec this skill checks.
- [reviewer](reviewer.md), [audit](audit.md), [audit-learning](audit-learning.md), and [release](release.md).
- [wiki](wiki.md), [rules](rules.md), and [sessions](sessions.md).

Source: [plugins/playbook/skills/close/SKILL.md](../../plugins/playbook/skills/close/SKILL.md)
