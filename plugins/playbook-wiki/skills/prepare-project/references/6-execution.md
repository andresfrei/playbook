# Stage 6 — Execution

The plan is built unit by unit. A unit is accepted as the plan says: by its evidence, or by the owner's judgement.

## Steps

1. Start every unit of the work's `plan.md` that is not Done and whose "Waits for" units are all Done, up to the plan's number of `write` agents at once. A unit Built and waiting for the owner holds only the units that wait for it. When an agent ends, start the next ready unit. For each unit started, in this order:
   1. Create its worktree from the work's branch: `git worktree add -b <unit branch> <folder> <work branch>`, with the unit's branch name from the plan. Do not use the Agent tool's `isolation: "worktree"`: it starts from the default branch.
   2. Prepare it as the plan says: run the install command in the folder, and copy the listed ignored files from the main folder. When the plan says the batch shares one worktree, skip the worktree and its preparation, and give each unit its exclusive paths.
   3. Start `write` in the background, with the absolute folder and the exact paths it may change. Start the agents of all the ready units as several Agent calls in one message.
   4. When its checks pass, after `review` when the unit is risky, merge it in the main folder on the work's branch with `git merge --no-ff <unit branch>`, and run the unit's checks there. Then run `git worktree remove <folder>` and `git branch -d <unit branch>`.
   5. On a conflict, resolve it and run the checks of both units again.
2. Each `write` agent builds its unit with the execution workflow that the session's instructions define, and the unit is delivered as the plan's delivery decisions say: its branch, and where it integrates. This skill adds no workflow of its own; when the instructions define none, build the unit directly. Create a document for a unit only when that workflow requires one.
3. When a definition is missing, ask the owner, record the decision in the wiki, and then continue. When one changes, do what the `write-docs` skill says for a changed definition.
4. When the unit's ending condition holds, record its evidence in the progress table: what was run and what was observed. Rewrite "Where work stands" as step 5 of the skill says, counting a unit accepted by evidence as Done, and run the check that step 6 names. When it passes:
   - A unit accepted by evidence: set it to Done, with the date. Ask the owner only what written decisions cannot resolve.
   - A unit accepted by judgement: set it to Built and ask the owner to review it. When the owner accepts it, set it to Done, with the date and the owner's words.
5. The acceptance of a unit is not a row of the work's `decisions.md`.
6. When every unit is Done, close the work before its last merge:
   - Measure and propose delegations, as the skill's file on delegation says for the close of a work.
   - When `docs/wiki/evidence.md` exists, propose the consolidations of repeated findings, as the skill's file on evidence says.
   - Rewrite the shared pages to say what the work decided, each statement citing its decision. Create a shared page when none covers it, and add it to the table of pages of the project's `README.md`.
   - In each row of the work's `decisions.md`, name the shared page it changed, or "none".
   - When git has a tag that is a version, such as `v1.2.0` or `1.2.0`, recommend whether the work needs a new version and which one, and ask the owner. Follow the project's own written rule of versions; without one, Semantic Versioning: MAJOR when the work breaks what users have, MINOR when it adds without breaking, PATCH for a fix, none when nothing reaches users. On a yes, record the version as a decision and list the release steps as next steps: the version in the project's files, the tag, and the release on the forge. Make the release only when asked.
   - When the plan names a place where the work is tested, take the work there as the plan says, and ask the owner to check it there. Each fix the check needs is a new unit of this work, built and delivered the same way, and updates the shared pages it changes. Go on only when the owner accepts the check.
   - List the worktrees left behind with `git worktree list`, and remove them.
   - Set the work's status to Closed with the date, and run the check.
   - Do the step at the merge that the contract describes.

## Project already started

Nothing differs.

## Closing condition

Every unit is Done, or the owner ends the plan, and the work is closed.
