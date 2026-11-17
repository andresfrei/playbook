# Stage 5 — Plan

The work is an ordered list of units. The plan says how each one is accepted: by its evidence, or by the owner's judgement.

## Steps

1. Take the units from the wiki: its flows, modules, and decisions. Add nothing the wiki does not contain.
2. Make each unit deliver one thing and end on a condition that can be observed: a check the owner can do, not a judgement.
3. Propose how each unit is accepted:
   - **evidence**: it is Done when its ending condition holds and the evidence is recorded. Recommend it when a check shows everything the unit must get right.
   - **judgement**: it also waits for the owner's review. Recommend it when the unit writes something a check cannot judge: a definition's text, an interface or a design people use, or how it fits requirements the checks do not cover.
   When unsure, recommend judgement. The owner settles each one by accepting the plan.
4. Order the units by what each one depends on.
5. Ask the owner how a unit is delivered. Record each answer as a decision:
   - whether each unit is built on its own branch or on the main branch;
   - whether a unit reaches the main branch by a pull request or by a local merge;
   - whether units that do not depend on each other may be built in parallel.
6. Write the work's `plan.md` with:
   - a progress table: unit, status, evidence, the date each unit is Done, and, for a unit accepted by judgement, the owner's words;
   - a units table: identifier (`<work>-U1`, `<work>-U2`, …), unit, what it delivers, when it ends, and accepted by: evidence or judgement;
   - how a unit is delivered, naming the decisions of step 5;
   - when parallel units are allowed, which units may be built together;
   - what is left out of the plan.
7. Ask the owner to accept the plan.

The status of a unit is one of: Not started, Built (waiting for the owner's review, for a unit accepted by judgement), Done.

## Project already started

The units cover only what is missing: what stage 1 wrote under "how to do what is missing", and what stages 2 to 4 decided to change.

For step 5, read from the repository's history how it delivers today, and propose that. It is Proposed until the owner confirms it.

## Closing condition

- Every unit has a condition that can be observed, and says how it is accepted.
- How a unit is delivered is decided.
- The owner accepts the plan.
- No unit has started.
