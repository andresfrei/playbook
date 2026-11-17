# Stage 1 — Wiki

Every definition of the product is written down and decided before any technology is chosen.

## A new project

A repository is one project with one wiki. A project with a wiki gets a new work, not a second wiki.

1. Ask the owner who the project's owner is, and the name of the first work and what it is for.
2. Create the project's `README.md` and the folder of the first work, with its stage table, as the format says.
3. From the project's root, run `sh <this skill's folder>/../doctor/scripts/wiki-format.sh mark docs/wiki`: it writes `docs/wiki/.format`, which says that the wiki is in the playbook's present format.
4. Ask the owner whether to write the two sentences of the format, under "The project's instruction file", in the project's `CLAUDE.md`. Create it when it is missing.

Then do the steps below.

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

1. Compare the owner's brief with the topics before asking anything. Mark each topic covered, partly covered, or missing.
2. Write the product pages, in the work's folder, from what the brief covers.
3. Write each missing or contradictory point as a question in the work's `questions.md`, with a recommendation and what it blocks. Do not ask about a topic the brief already covers.
4. Ask the questions, starting with the one that blocks the most. Record each answer as a decision and update the pages it affects.

## Project already started

Write the wiki in this order:

1. The definitions, with the steps above.
2. What exists today, in a page of the work that becomes `02-current-state/` when the work closes: the code and what it does, the technology in use, and the debt. Read the repository to write it, and say what was checked by reading or running and what was not.
3. How to do what is missing: what separates the definitions from what exists today.

For the definitions:

- Read the documents the repository already holds, such as a README or design notes, next to the owner's brief. They are a source for steps 1 and 2 above.
- What a document says is Proposed until the owner confirms it. Never write it as Decided.
- Write a point that is ambiguous, or where a document and the code differ, as an open question with its possible readings. Do not choose a reading.

## Closing condition

- Every topic is covered, or the owner said it does not apply.
- No open question blocks stage 2.
- For a project already started, the three parts above are written.
- The owner accepts the wiki.
