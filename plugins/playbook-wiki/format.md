# The format of a wiki

Format 4. The files of a project's wiki, `docs/wiki/`, and what each one holds. The skills of `playbook-wiki` write and repair a wiki to this format, and its check verifies it.

## Two layers

- The shared pages say how the project is now. They are what an agent reads to understand the project.
- The folder of each work, under `works/`, is the history: its decisions, their reasons, who decided, its questions, and its plan.
- Before a work is merged, what it defined is written in the shared pages, and each statement cites its decision.

A work is what one branch carries from its start to its merge: a phase with its six stages, or a smaller change.

## Files

```text
docs/wiki/
├── README.md            # the entry point: the project, its owner, the shared pages
├── .format              # the format of the wiki; a script writes it, never by hand
├── 01-product/          # shared pages: overview, glossary, one page per topic
├── 02-current-state/    # shared: what existed before, in a project already started
├── 03-technology/       # shared
├── 04-skills/           # shared
├── 05-design-system/    # shared
└── works/
    └── <work>/
        ├── README.md    # where the work stands, its stage table, its own pages
        ├── decisions.md
        ├── questions.md
        ├── plan.md
        └── ...          # the work's own pages, when it needs them
```

Create a folder or a page only when it has content. One topic per page.

A wiki written before format 4 also holds `decisions.md` and the pages of its earlier phases. They are history: they stay as they are, nothing is added to that `decisions.md`, and the check does not read it. Its identifiers, `D#`, `TD#`, `Q#`, and `U#`, are never renumbered.

## The project's `README.md`

In this order:

1. What the project is, in one or two sentences, and which document wins: the wiki over any other document, and inside the wiki a decision over the rest.
2. The project's owner, by name. The owner decides what more than one work shares.
3. The three statuses of a statement: Decided, Proposed, Open.
4. A table of the shared pages: each page, what it contains, and the code it governs: the paths, from the project's root, whose behaviour the page defines. Leave the cell empty for a page that defines no code. Prefer a folder to a list of files.

Title the third column "Code it governs" and write each path as code, between backticks. The check fails on a path that does not exist.

The project's `README.md` holds no state and no list of works: the folders under `works/` are that list.

## A work

A branch becomes a work at its first decision, question, or plan. Recording the first one creates the work's folder. Before that the branch needs no folder.

The folder's name is the work's name: lowercase letters, digits, and hyphens, such as `auth` or `rbac-approvals`. It is never the name of another folder under `works/`, open or closed.

A closed work is never reopened. A later change to what it defined is a new work, with a new name.

### The work's `README.md`

In this order:

1. What the work is for, in one or two sentences, and who leads it. The person who leads a work decides inside it.
2. Its status: Open, or Closed with the date of its merge.
3. "Where work stands", as described below.
4. Its stage table, when the work is a phase.
5. A table of the work's own pages, with the same three columns as the project's table.

### "Where work stands"

Its heading is `## Where work stands`. The section holds, in at most 250 words:

- the date and the identifier of the work's last decision;
- the stage that is open, or that none is;
- what waits for a decision, as links to the pages;
- the next steps, in order.

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

## Identifiers

An identifier is the work's name and a counter of that work, kept in the work's files:

| Item | Identifier | File |
|------|------------|------|
| Decision | `auth-3` | `decisions.md` |
| Question | `auth-Q2` | `questions.md` |
| Unit of the plan | `auth-U1` | `plan.md` |

Each counter starts at 1 and is never reused.

## A work's `decisions.md`

One table: ID, date, decision, who decided, their words, shared page.

- Who decided: the person who leads the work, or the project's owner for a decision that changes a definition other works share.
- Their words are verbatim. When that person chose one of the options offered, write the option chosen.
- Shared page: the path of the shared page the decision changed, from `docs/wiki/` and as code, such as `01-product/rbac.md`; or "none". That page cites the decision.
- A decision that replaces an earlier one names it, in this work or in another.
- A decision is a choice made between alternatives, or a rule set. That includes an authorization given before an action, the closing of a stage, and the acceptance of a plan.
- Not a row: the acceptance of a unit, which goes in the plan's progress table, and something done after a decision, such as a push or a cleanup.
- State the choice in at most 60 words and link to the page that holds the detail. Evidence and reasons live in that page; their words are not counted.

## A work's `questions.md`

One table: identifier, question, recommendation, what it blocks. An answered question leaves this page and becomes a decision.

## A shared page

A shared page says only the definition in force. Each statement that a decision made cites it, such as `(auth-3)`.

When a definition changes and code stays on the old one, the page lists that code under the heading `## Code on the old definition`: one table with the path, the decision that changed the definition, and what was chosen, "changed when next touched" or "debt". Remove a row when its code is changed, and the heading when the table is empty.

Write the path in the first column, as code. The check fails on a path that does not exist.

`01-product/glossary.md` holds each term and its one meaning. Use the same word for the same thing in every page.

## The project's instruction file

The wiki's one text outside `docs/wiki/` is these two sentences, in the project's `CLAUDE.md`, written after asking the person:

> Read `docs/wiki/README.md` first. Before you change code, read the page that its page table names for the paths you change.

In a file that exists, add the two sentences and change nothing else.
