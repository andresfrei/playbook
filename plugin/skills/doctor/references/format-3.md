# Format 3 — a table of pages that says which code each page governs

What changed in the format of a wiki, and how a wiki at format 2 reaches format 3.

## What changed

- The table of pages in `docs/wiki/README.md` has a third column, "Code it governs": the paths whose behaviour each page defines.
- A page that states a definition lists the code left on an old definition under a heading "Code on the old definition".
- The check of the wiki fails on a path named in either place that does not exist in the project, and on a row of `decisions.md` whose decision has more than 60 words.
- The project's instruction file tells a session to read the page that governs a path before it changes the code.

The first two are defined in `../../prepare-project/references/1-wiki.md`, under "`README.md`" and "A page that states a definition". Read both sections before step 1.

The limit of 60 words applies to the rows written from now on. Nothing already in `decisions.md` changes, and no text moves.

## Steps

1. Read the table of pages in `docs/wiki/README.md`. For each page that defines how code behaves, find in the repository the paths it governs. Prefer a folder to a list of files. A page that defines no code, such as a glossary or a plan, gets an empty cell.
2. Show the owner the table with the new column. Write what the owner accepts: the column "Code it governs", each path as code, between backticks, from the project's root.
3. Ask the owner whether a definition that changed in the past left code on the old one. For each case the owner names, add the section "Code on the old definition" to the page that states the definition. Do not search the code for such cases.
4. Do step 2 of the Steps in `../../prepare-project/references/1-wiki.md`: the two sentences in the project's instruction file. Those files are outside `docs/wiki/`, and they are the only ones this repair changes there.
5. Continue with the last step of the skill. `wiki-format.sh mark` also writes `docs/wiki/.unchecked-decisions`, which holds how many rows `decisions.md` has now: the check does not read those rows.
