# Stage 6 — Execution

The plan is built unit by unit, and the owner reviews each unit when it ends.

## Steps

1. Take the first unit of the work's `plan.md` that is not Done. Do not start a unit before the owner has reviewed the one before it. When the plan allows parallel units, take with it the units the plan says may be built together.
2. Build the unit with the execution workflow that the session's instructions define, and deliver it as the plan says: its branch, and how it reaches the main branch. This skill adds no workflow of its own. Create a document for a unit only when that workflow requires one.
3. When a definition is missing, ask the owner, record the decision in the wiki, and then continue. When one changes, do what the `write-docs` skill says for a changed definition.
4. When the unit's ending condition holds, set the unit to Built in the progress table, with the evidence: what was run and what was observed. Rewrite "Where work stands" in the work's `README.md` and run the check from the project's root: `sh <this skill's folder>/../../check-wiki.sh docs/wiki`. When it passes, ask the owner to review the unit.
5. When the owner accepts the unit, set it to Done in the progress table, with the date and the owner's words. The acceptance is not a row of the work's `decisions.md`.
6. When every unit is Done, close the work before it is merged:
   - Rewrite the shared pages to say what the work decided, each statement citing its decision. Create a shared page when none covers it, and add it to the table of pages of the project's `README.md`.
   - In each row of the work's `decisions.md`, name the shared page it changed, or "none".
   - Set the work's status to Closed with the date, and run the check.
   - Do the step at the merge that the contract describes.

## Project already started

Nothing differs.

## Closing condition

Every unit is Done, or the owner ends the plan, and the work is closed.
