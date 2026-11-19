# Stage 6 — Execution

The plan is built unit by unit. A unit is accepted as the plan says: by its evidence, or by the owner's judgement.

## Steps

1. Take the first unit of the work's `plan.md` that is not Done. Do not start a unit before the one before it is Done. When the plan allows parallel units, take with it the units the plan says may be built together.
2. Build the unit with the execution workflow that the session's instructions define, and deliver it as the plan's delivery decisions say: its branch, and where it integrates. This skill adds no workflow of its own; when the instructions define none, build the unit directly. Create a document for a unit only when that workflow requires one.
3. When a definition is missing, ask the owner, record the decision in the wiki, and then continue. When one changes, do what the `write-docs` skill says for a changed definition.
4. When the unit's ending condition holds, record its evidence in the progress table: what was run and what was observed. Rewrite "Where work stands" as step 5 of the skill says, counting a unit accepted by evidence as Done, and run the check that step 6 names. When it passes:
   - A unit accepted by evidence: set it to Done, with the date. Ask the owner only what written decisions cannot resolve.
   - A unit accepted by judgement: set it to Built and ask the owner to review it. When the owner accepts it, set it to Done, with the date and the owner's words.
5. The acceptance of a unit is not a row of the work's `decisions.md`.
6. When every unit is Done, close the work before its last merge:
   - Measure and propose delegations, as the skill's file on delegation says for the close of a work.
   - Rewrite the shared pages to say what the work decided, each statement citing its decision. Create a shared page when none covers it, and add it to the table of pages of the project's `README.md`.
   - In each row of the work's `decisions.md`, name the shared page it changed, or "none".
   - When git has a tag that is a version, such as `v1.2.0` or `1.2.0`, recommend whether the work needs a new version and which one, and ask the owner. Follow the project's own written rule of versions; without one, Semantic Versioning: MAJOR when the work breaks what users have, MINOR when it adds without breaking, PATCH for a fix, none when nothing reaches users. On a yes, record the version as a decision and list the release steps as next steps: the version in the project's files, the tag, and the release on the forge. Make the release only when asked.
   - When the plan names a place where the work is tested, take the work there as the plan says, and ask the owner to check it there. Each fix the check needs is a new unit of this work, built and delivered the same way, and updates the shared pages it changes. Go on only when the owner accepts the check.
   - Set the work's status to Closed with the date, and run the check.
   - Do the step at the merge that the contract describes.

## Project already started

Nothing differs.

## Closing condition

Every unit is Done, or the owner ends the plan, and the work is closed.
