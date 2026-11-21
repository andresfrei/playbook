---
name: migrate
description: Bring this project's wiki to the current wiki format, or repair a wiki that fails its check. Only the owner starts it, usually after a session notice said the wiki's format is behind.
context: fork
agent: playbook-wiki:wiki-writer
disable-model-invocation: true
---

## When to use

- The owner starts it, usually after a notice at the start of a session said that the wiki has no format marker or that its format is behind.
- The owner asks to repair a wiki at the current format that fails `check-wiki.sh`.

Do not use it to write, extend, or reorganize a wiki for any other reason.

## Rules

- Change only files under `docs/wiki/`.
- This skill holds no knowledge of any older format. The current format is `<this skill's folder>/../../format.md`; read it, and the wiki, every time.
- Migrate without proposing first: the owner starting you is the acceptance (decision-index-15). Change what the steps say, run the check, and return what changed and every estimated value. Git is the undo.
- Move text. Do not rewrite it, shorten it, or delete it, except a copy of something that another page of the wiki already holds.
- Keep every decision's identifier, date, words, and who decided.
- A value you fill by reading a row, not from the owner's words, ends in ` (estimated)`. Leave a cell empty rather than guess.
- Never write `docs/wiki/.format` by hand. Only `scripts/wiki-format.sh mark` writes it, and only when the check passes.
- When the project is not a git repository, copy `docs/wiki/` to a folder next to it before the first change, and report where the copy is.

## Steps

1. When the project has no `docs/wiki/README.md`, say so and stop.
2. Read `format.md`. From the project's root, run `sh <this skill's folder>/scripts/wiki-format.sh status docs/wiki`, and run `sh <this skill's folder>/../../check-wiki.sh --ignore-marker docs/wiki`. The option skips only the marker gate, so the check reports the rest on a wiki whose marker is old. When the status prints nothing and the check passes, report that the wiki is at the current format, and stop.
3. Read the wiki: every page and every `decisions.md`. Compare it with `format.md` and list what differs.
4. When the status printed a line, rewrite the wiki to the current format:
   - Add each column the format requires. For Replaces, fill a row only where its own text says it replaces a decision entirely, not a part of it, mark the value ` (estimated)`, and otherwise leave it empty. Fill Kind and Answer the same way, or leave them empty where the format allows.
   - For each row whose Shared page is none or empty, find the shared pages, outside `works/`, that cite its identifier as a whole word. Write all of them as code, separated by `, `, and mark the cell ` (estimated)`. Leave it none when no page cites it.
   - Turn a `docs/wiki/decisions.md` at the top into `docs/wiki/works/history/decisions.md`, with the columns the format gives a work's table.
   - Move to the files and sections that the format names whatever it places elsewhere. Text that the format no longer allows where it is, such as the stage tables of phases before format 4 in `README.md`, moves whole to a page of its own under the folder that fits, such as `05-plan/`, which you add to the page table of `README.md`; delete nothing.
5. Run `sh <this skill's folder>/../../check-wiki.sh --ignore-marker docs/wiki`. Repair what it reports and run it again until it passes.
6. When the status printed a line, run `sh <this skill's folder>/scripts/wiki-format.sh mark docs/wiki`. When it fails, repair what it reports and run it again.

## Output

- Each page changed, and what moved from where to where.
- Every value you wrote with ` (estimated)`, as a list of the decision, the column, and the value, so the owner can read them.
- The last line that the check and, when it ran, `wiki-format.sh mark` printed.
