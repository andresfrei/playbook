# Stage 5 — Plan

The work is an ordered list of units that the owner reviews one by one.

## Steps

1. Take the units from the wiki: its flows, modules, and decisions. Add nothing the wiki does not contain.
2. Make each unit deliver one thing and end on a condition that can be observed: a check the owner can do, not a judgement.
3. Order the units by what each one depends on.
4. Ask the owner how a unit is delivered, one question at a time. Record each answer as a decision:
   - whether each unit is built on its own branch or on the main branch;
   - whether a unit reaches the main branch by a pull request or by a local merge;
   - whether units that do not depend on each other may be built in parallel.
5. Write `06-plan/plan.md` with:
   - a progress table: unit, status, evidence, and, once the owner accepts the unit, the date and the owner's words;
   - a units table: number (`U1`, `U2`, …), unit, what it delivers, and when it ends;
   - how a unit is delivered, naming the decisions of step 4;
   - when parallel units are allowed, which units may be built together;
   - what is left out of the plan.
6. Ask the owner to accept the plan.

The status of a unit is one of: Not started, Built (waiting for the owner's review), Done.

## Project already started

The units cover only what is missing: what stage 1 wrote under "how to do what is missing", and what stages 2 to 4 decided to change.

For step 4, read from the repository's history how it delivers today, and propose that. It is Proposed until the owner confirms it.

## Closing condition

- Every unit has a condition that can be observed.
- How a unit is delivered is decided.
- The owner accepts the plan.
- No unit has started.
