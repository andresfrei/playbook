---
name: migrate
description: Bring this project's wiki to the current wiki format, or repair a wiki that fails its check. Only the owner starts it, usually after a session notice said the wiki's format is behind.
disable-model-invocation: true
---

## When to use

- The owner starts it, usually after a notice at the start of a session said that the wiki has no format marker or that its format is behind.
- The owner asks to repair a wiki at the current format that fails `check-wiki.sh`.

Do not use it to write, extend, or reorganize a wiki for any other reason.

## Rules

- Change only files under `docs/wiki/`.
- This skill holds no knowledge of any older format. The current format is `<this skill's folder>/../../format.md`; read it, and the wiki, every time.
- Propose before you change. List the rewrites, wait for the owner's answer, and apply only what the owner accepts.
- Move text. Do not rewrite it, shorten it, or delete it, except a copy of something that another page of the wiki already holds.
- Keep every decision's identifier, date, words, and who decided.
- A value you fill by reading a row, not from the owner's words, ends in ` (estimated)`. Leave a cell empty rather than guess.
- Never write `docs/wiki/.format` by hand. Only `scripts/wiki-format.sh mark` writes it, and only when the check passes.
- When the project is not a git repository, copy `docs/wiki/` to a folder next to it before the first change, and tell the owner where the copy is.

## Steps

1. When the project has no `docs/wiki/README.md`, say so and stop.
2. Read `format.md`. From the project's root, run `sh <this skill's folder>/scripts/wiki-format.sh status docs/wiki`, and run `sh <this skill's folder>/../../check-wiki.sh docs/wiki`. When the status prints nothing and the check passes, tell the owner that the wiki is at the current format, and stop.
3. Read the wiki: every page and every `decisions.md`. Compare it with `format.md` and list what differs.
4. When the status printed a line, rewrite the wiki to the current format:
   - Add each column the format requires. For Replaces, fill a row only where its own text names a decision it replaces, changes, or narrows, mark the value ` (estimated)`, and otherwise leave it empty. Fill Kind and Answer the same way, or leave them empty where the format allows.
   - Turn a `docs/wiki/decisions.md` at the top into `docs/wiki/works/history/decisions.md`, with the columns the format gives a work's table.
   - Move to the files and sections that the format names whatever it places elsewhere.
5. Fix what the check reports, whether or not the status printed a line.
6. Run the check again until it passes. When the status printed a line, then run `sh <this skill's folder>/scripts/wiki-format.sh mark docs/wiki`. When it fails, repair what it reports and run it again.

## Output

- Each page changed, and what moved from where to where.
- Every value you wrote with ` (estimated)`, as a list of the decision and the value, for the owner to read.
- What the owner did not accept.
- The last line that the check and, when it ran, `wiki-format.sh mark` printed.
