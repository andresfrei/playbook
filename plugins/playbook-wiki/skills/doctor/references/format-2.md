# Format 2 — a state section that says only the current state

What changed in the format of a wiki, and how a wiki written before the change reaches it.

## What changed

- "Where work stands", in `docs/wiki/README.md`, holds only the current state, in at most 250 words. What it holds is defined in `../../../format.md`, the format of a wiki, under "Where work stands". Read that section before step 3.
- A decision is a choice or a rule of the owner, stated in at most 60 words with a link to the page that holds the detail. The acceptance of a unit is written in the plan's progress table.

The second point applies to what is written from now on. Nothing already in `decisions.md` or in a plan changes.

## Steps

1. Look for a stage table in `docs/wiki/README.md`. When there is none, the wiki was written before `prepare-project` existed: tell the owner that it adopts the format through "Project already started" in `prepare-project`, and stop. Do not run `wiki-format.sh mark`.
2. Read "Where work stands" and the plan page of each phase, `06-plan/` or the folder the wiki uses for its plans.
3. Sort every sentence of "Where work stands" into one of four:
   - the current state, which stays;
   - what a finished phase or unit left, or what was not verified when it closed, which moves to the plan page of that phase, under a heading "What the phase left". This heading is the one thing the repair adds to the pages of an earlier phase. When a phase has no plan page, ask the owner which page takes the text;
   - a copy of a decision: remove only the words that the row of that number in `decisions.md`, or the page that row links to, already holds. A reason or a measurement that neither holds moves with the next kind. When `decisions.md` has no row with that number, keep the sentence and report it to the owner;
   - a measurement or a description, which moves to the page of its topic.
4. Write the new section: the heading `## Where work stands`, a first line "Updated" with the date and the last decision, the phase and the stage that are open or that none is, what waits for the owner as links, the next steps in order, and one line for each finished phase with a link to its plan page.
5. Show the owner the new section and the list of what moves where. Apply what the owner accepts.
6. Check that every sentence of the old section is in the new section, in the page it moved to, or already held by the row or the page named in step 3. Report any that is in none.
