# Stage 5 — Plan

The work is an ordered list of units. The plan says how each one is accepted: by its evidence, or by the owner's judgement.

## Steps

1. Take the units from the wiki: its flows, modules, and decisions. Add nothing the wiki does not contain.
2. Make each unit deliver one thing and end on a condition that can be observed: a check the owner can do, not a judgement.
3. Propose how each unit is accepted:
   - **evidence**: it is Done when its ending condition holds and the evidence is recorded. Recommend it when a check shows everything the unit must get right.
   - **judgement**: it also waits for the owner's review. Recommend it when the unit writes something a check cannot judge: a definition's text, an interface or a design people use, or how it fits requirements the checks do not cover.
   When unsure, recommend judgement. The owner settles each one by accepting the plan.
4. Order the units by what each one depends on. Step 6 writes that order in the column "Waits for".
5. Ask the owner how the work is delivered. Assume no branch and no workflow. Record each answer as a decision.
   - Read the sources first, and say what you read and where. The project's own skill for delivery, when there is one, such as a skill in `.claude/skills/` or one that `CLAUDE.md`, `AGENTS.md`, or `CONTRIBUTING.md` names: take it into account. Then git: `git branch -a`, and `git log --merges --first-parent` on each long-lived branch. A source informs the recommendation; it is not the proposal.
   - Where the work is tested. Ask; do not infer it:
     - its own branch, deployed for instance from a worktree, checked before any merge;
     - a shared branch people test on, checked after the merge to it;
     - nowhere apart: only the tests and the checks.
   - Which branch is production. Read it, then confirm it.
   - How the units integrate. Offer the three ways with their cost, and recommend one:

     | Way | Fits | Costs |
     |-----|------|-------|
     | One pull request for the whole work | A small work | One large review |
     | A work branch, with a draft tracker pull request to where the work goes; each unit reaches the work branch by a pull request or a local merge, and the work leaves it by one merge | Most works | The work waits until every unit is Done |
     | Each unit straight to the branch people test on | Each unit can be tested alone | A partial work where people test |

     With local merges there is no tracker: the work branch holds the work. Open a pull request only when the owner says so.
   - How branches are named. Follow the project's own convention. Without one, recommend `<type>/<work>`, with the types of conventional commits, such as `feat/user-login`, and for a unit on its own branch `<type>/<work>-<NN>-<slice>`, such as `feat/user-login-01-core`.

   When a proposal, from a source or from the owner, would leave an unfinished work on a branch people test on, name the risk and recommend a way that keeps that branch whole. The owner decides.
6. Write the work's `plan.md` with:
   - a progress table: unit, status, evidence, the date each unit is Done, and, for a unit accepted by judgement, the owner's words;
   - a units table: identifier (`<work>-U1`, `<work>-U2`, …), unit, what it delivers, when it ends, waits for, and accepted by: evidence or judgement. "Waits for" holds the identifiers of the units that one waits for, or "none". A unit waits for another when it uses what that one builds. Sharing a file is not waiting;
   - a "Batches" table, with the columns batch and units, that follows from "Waits for": batch 1 holds the units that wait for none, batch 2 those that wait only for units of batch 1, and so on;
   - the most `write` agents that run at once. Recommend a number; the owner accepts it with the plan;
   - how a new worktree is prepared: the command that installs the dependencies, or none, and the ignored files to copy from the main folder, such as `.env`, or none. When preparing a worktree costs too much, the units of a batch share one worktree, each with exclusive paths;
   - how the work is delivered, naming the decisions of step 5;
   - what is left out of the plan.
7. Ask the owner to accept the plan.

The status of a unit is one of: Not started, Built (waiting for the owner's review, for a unit accepted by judgement), Done.

## Project already started

The units cover only what is missing: what stage 1 wrote under "how to do what is missing", and what stages 2 to 4 decided to change.

For step 5, how the repository delivers today is a source, not the proposal. When it delivers units one by one to a branch people test on, say so as a risk, and recommend a way that keeps that branch whole.

## Closing condition

- Every unit has a condition that can be observed, and says how it is accepted.
- How the work is delivered is decided: where it is tested, how its units integrate, and how its branches are named.
- The owner accepts the plan.
- No unit has started.
