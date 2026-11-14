---
name: doctor
description: Repair this project's wiki after the playbook changed the format of a wiki. Only the owner starts it.
disable-model-invocation: true
---

## When to use

- The owner starts it, usually after a notice at the start of a session said that the wiki has no format marker or that its format is behind.

Do not use it to write, extend, or reorganize a wiki for any other reason.

## Rules

- Change only files under `docs/wiki/`. The copy that the last rule asks for is the one exception.
- Propose before you change. List every repair, wait for the owner's answer, and apply only what the owner accepts.
- Move text. Do not rewrite it, shorten it, or delete it, except a copy of something that another page of the wiki already holds.
- Never change, renumber, or delete a row of `docs/wiki/decisions.md`.
- Do one format at a time, in order, from the wiki's format to the playbook's.
- Never write `docs/wiki/.format` by hand. Only `scripts/wiki-format.sh mark` writes it, and only when the check passes.
- When the project is not a git repository, copy `docs/wiki/` to a folder next to it before the first change, and tell the owner where the copy is.

## Steps

1. When the project has no `docs/wiki/README.md`, say so and stop.
2. From the project's root, run `sh <this skill's folder>/scripts/wiki-format.sh status docs/wiki`. When it prints nothing, tell the owner that the wiki is at the playbook's format, and stop.
3. Read the wiki's format: the number in `docs/wiki/.format`. When the file is missing, or does not hold a number of 2 or more, the wiki is at format 1.
4. For each format after the wiki's, up to the one the notice names, read `references/format-<number>.md` and do its steps.
5. Unless a reference file told you to stop, run `sh <this skill's folder>/scripts/wiki-format.sh mark docs/wiki`. It runs the check of the wiki and writes the marker only when the check passes. When it fails, repair what it reports, with the owner's answer, and run it again.

## Output

- Each page changed, and what moved from where to where.
- What the owner did not accept.
- The last line that `wiki-format.sh mark` printed.

## References

- `references/format-2.md` — how a wiki reaches format 2: a state section that says only the current state.
