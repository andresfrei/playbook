# Stage 1 — Wiki

Every definition of the product is written down and decided before any technology is chosen.

## Files

The files of a wiki and what each one holds are in `../../../format.md`, the format of a wiki. Read it before you write the wiki.

## A new phase

A phase is a second round of the six stages for a project whose six stages are closed. It starts only when the owner asks for it.

1. Record the new phase as a decision, with the owner's words.
2. Add a stage table for the new phase above the existing one, with stage 1 Open and the others Not started. Title each table with its phase. Keep the earlier table as a record, and never reopen one of its stages.
3. Do the six stages for the new phase as for a project already started.
4. Write the new phase in pages of its own, next to the existing ones. Do not rewrite the pages of the earlier phase.
5. Continue the numbers of decisions, questions, and units. None starts again at 1.

## Topics a product definition covers

- The problem, and who has it.
- Who uses the product, and what each kind of user does with it.
- The main flows, from start to end.
- What the product must do.
- What it must not do, and what waits for a later version.
- The qualities it needs: speed, availability, security, privacy, a record of who did what.
- The limits it works within: budget, dates, law, systems that already exist.
- The outside systems it exchanges data with.
- The volume expected: users, data, and their growth.
- Who runs and maintains it.
- Its business rules, its states, and its vocabulary.

## Steps

1. Create the project's `README.md` as the format says. Then, from the project's root, run `sh <this skill's folder>/../doctor/scripts/wiki-format.sh mark docs/wiki`: it writes `docs/wiki/.format`, which says that the wiki is in the playbook's present format.
2. Ask the owner whether to write the two sentences of the format, under "The project's instruction file", in the project's `CLAUDE.md`. Create it when it is missing.
3. Compare the owner's brief with the topics before asking anything. Mark each topic covered, partly covered, or missing.
4. Write the product pages from what the brief covers. Mark each statement Decided, Proposed, or Open.
5. Write each missing or contradictory point as an open question, with a recommendation and what it blocks. Do not ask about a topic the brief already covers.
6. Ask the open questions one at a time, starting with the one that blocks the most. Record each answer as a decision and update the pages it affects.

## Project already started

Write the wiki in this order:

1. The definitions, with the steps above.
2. What exists today, in `02-current-state/`: the code and what it does, the technology in use, and the debt. Read the repository to write it, and say what was checked by reading or running and what was not.
3. How to do what is missing: what separates the definitions from what exists today.

For the definitions:

- Read the documents the repository already holds, such as a README or design notes, next to the owner's brief. They are a source for steps 3 and 4 above.
- What a document says is Proposed until the owner confirms it. Never write it as Decided.
- Write a point that is ambiguous, or where a document and the code differ, as an open question with its possible readings. Do not choose a reading.

## Closing condition

- Every topic is covered, or the owner said it does not apply.
- No open question blocks stage 2.
- For a project already started, the three parts above are written.
- The owner accepts the wiki.
