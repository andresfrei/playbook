# Stage 1 — Wiki

Every definition of the product is written down and decided before any technology is chosen.

## Files

```text
docs/wiki/
├── README.md           # the single entry point
├── .format             # the format of the wiki; a script writes it, never by hand
├── decisions.md        # the numbered decisions
├── 01-product/         # overview, glossary, open-questions, one page per topic
├── 02-current-state/   # a project already started only
├── 03-technology/      # written in stage 2
├── 04-skills/          # written in stage 3
├── 05-design-system/   # written in stage 4
└── 06-plan/            # written in stage 5
```

Create a folder or a page only when it has content. One topic per page.

### `README.md`

In this order:

1. What the project is, in one or two sentences, and which document wins: the wiki over any other document, and `decisions.md` over the rest of the wiki.
2. The three statuses of a statement: Decided, Proposed, Open.
3. "Where work stands": the current state only, as described below.
4. The stage table.
5. A table of the pages: each page and what it contains.

### "Where work stands"

Its heading is `## Where work stands`. The section holds, in at most 250 words:

- the date and the number of the last decision;
- the phase and the stage that are open, or that none is;
- what waits for the owner, as links to the pages;
- the next steps, in order;
- one line for each finished phase, with a link to the page that holds what it left.

It never holds the text of a decision, what a finished unit did, or a measurement: link to them. Rewrite the section each time; do not add to it.

### Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Open | |
| 2 Technology | Not started | |
| 3 Skills | Not started | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

A status is one of: Not started, Open, Closed, Closed (not applicable).

### A new phase

A phase is a second round of the six stages for a project whose six stages are closed. It starts only when the owner asks for it.

1. Record the new phase as a decision, with the owner's words.
2. Add a stage table for the new phase above the existing one, with stage 1 Open and the others Not started. Title each table with its phase. Keep the earlier table as a record, and never reopen one of its stages.
3. Do the six stages for the new phase as for a project already started.
4. Write the new phase in pages of its own, next to the existing ones. Do not rewrite the pages of the earlier phase.
5. Continue the numbers of decisions, questions, and units. None starts again at 1.

### `decisions.md`

One table: ID, date, decision, owner's words.

- `D#` numbers a product decision, `TD#` a technical one.
- The owner's words are verbatim. When the owner chose one of the options offered, write the option chosen.
- A decision that replaces an earlier one names it.
- A decision is a choice the owner made between alternatives, or a rule the owner set. That includes an authorization given before an action, the closing of a stage or a phase, and the acceptance of a plan.
- Not a row: the acceptance of a unit, which goes in the plan's progress table, and something done after a decision, such as a push or a cleanup.
- State the choice in at most 60 words and link to the page that holds the detail. Evidence and reasons live in that page.

### `01-product/open-questions.md`

One table: number, question, recommendation, what it blocks. An answered question leaves this page and becomes a decision. A number is never reused.

### `01-product/glossary.md`

Each term and its one meaning. Use the same word for the same thing in every page.

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

1. Create `README.md` and `decisions.md` as described under Files. Then, from the project's root, run `sh <this skill's folder>/../doctor/scripts/wiki-format.sh mark docs/wiki`: it writes `docs/wiki/.format`, which says that the wiki is in the playbook's present format.
2. Compare the owner's brief with the topics before asking anything. Mark each topic covered, partly covered, or missing.
3. Write the product pages from what the brief covers. Mark each statement Decided, Proposed, or Open.
4. Write each missing or contradictory point as an open question, with a recommendation and what it blocks. Do not ask about a topic the brief already covers.
5. Ask the open questions one at a time, starting with the one that blocks the most. Record each answer as a decision and update the pages it affects.

## Project already started

Write the wiki in this order:

1. The definitions, with the steps above.
2. What exists today, in `02-current-state/`: the code and what it does, the technology in use, and the debt. Read the repository to write it, and say what was checked by reading or running and what was not.
3. How to do what is missing: what separates the definitions from what exists today.

For the definitions:

- Read the documents the repository already holds, such as a README or design notes, next to the owner's brief. They are a source for steps 2 and 3 above.
- What a document says is Proposed until the owner confirms it. Never write it as Decided.
- Write a point that is ambiguous, or where a document and the code differ, as an open question with its possible readings. Do not choose a reading.

## Closing condition

- Every topic is covered, or the owner said it does not apply.
- No open question blocks stage 2.
- For a project already started, the three parts above are written.
- The owner accepts the wiki.
