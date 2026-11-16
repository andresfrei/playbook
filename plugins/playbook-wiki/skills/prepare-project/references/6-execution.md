# Stage 6 — Execution

The plan is built unit by unit, and the owner reviews each unit when it ends.

## Steps

1. Take the first unit of `06-plan/plan.md` that is not Done. Do not start a unit before the owner has reviewed the one before it. When the plan allows parallel units, take with it the units the plan says may be built together.
2. Build the unit with the execution workflow that the session's instructions define, and deliver it as the plan says: its branch, and how it reaches the main branch. This skill adds no workflow of its own. Create a document for a unit only when that workflow requires one.
3. When a definition is missing, ask the owner, record the decision in the wiki, and then continue. When one changes, do what the `write-docs` skill says for a changed definition.
4. When the unit's ending condition holds, set the unit to Built in the progress table, with the evidence: what was run and what was observed. Rewrite "Where work stands" to the current state and run the check from the project's root: `sh <this skill's folder>/../../check-wiki.sh docs/wiki`. When it passes, ask the owner to review the unit.
5. When the owner accepts the unit, set it to Done in the progress table, with the date and the owner's words. The acceptance is not a row of `decisions.md`.
6. When the owner closes the phase, move what the phase left to the plan page of that phase, keep one line with a link to it in "Where work stands", and run the check again.

## Project already started

Nothing differs.

## Closing condition

Every unit is Done, or the owner ends the plan.
