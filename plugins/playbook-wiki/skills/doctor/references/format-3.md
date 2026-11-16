# Format 3 — a table of pages that says which code each page governs

What changed in the format of a wiki, and how a wiki at format 2 reaches format 3.

## What changed

- The table of pages in `docs/wiki/README.md` has a third column, "Code it governs": the paths whose behaviour each page defines.
- A page that states a definition lists the code left on an old definition under a heading "Code on the old definition".
- The check of the wiki fails on a path named in either place that does not exist in the project.
- The project's instruction file tells a session to read the page that governs a path before it changes the code.

The first two are defined in `../../../format.md`, the format of a wiki, under "The project's `README.md`" and "A shared page". Read both sections before step 1.

Nothing in `decisions.md` changes, and no text moves.

## Steps

1. Read the table of pages in `docs/wiki/README.md`. For each page that defines how code behaves, find in the repository the paths it governs. Prefer a folder to a list of files. A page that defines no code, such as a glossary or a plan, gets an empty cell.
2. Show the owner the table with the new column. Write what the owner accepts: the column "Code it governs", each path as code, between backticks, from the project's root.
3. Ask the owner whether a definition that changed in the past left code on the old one. For each case the owner names, add the section "Code on the old definition" to the page that states the definition. Do not search the code for such cases.
4. Ask the owner whether to write the two sentences of `../../../format.md`, under "The project's instruction file", in the project's `CLAUDE.md`. Those files are outside `docs/wiki/`, and they are the only ones this repair changes there.
5. Continue with the next format, when the playbook is above format 3, or with the last step of the skill.
