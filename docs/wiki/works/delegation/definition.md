# Definition of the work delegation

What this work must make true: a question reaches the owner only when the owner's answer can change something. The rest is decided once, by a delegation the owner records, and the agent acts within it (delegation-1).

## The problem

The playbook asks the owner many questions whose answer is already known. In nine wikis, 83% of the questions that close a stage were accepted as is, and half of all definitions were accepted as recommended ([measurements.md](measurements.md)). Each such question costs the owner attention and trains approval without reading.

The rules make every decision a question asked each time: R6 ("Only the owner decides ... a missing definition is asked, never invented"), D8 (each stage closed by the owner), and R14 (push, pull requests, and merges are the owner's). D208 asked the agent, for phase 4, to ask only what written decisions cannot resolve, and phase-4-1 lets a unit be accepted by its evidence; closing a stage, merging, and accepting a recommended definition are still asked each time.

## Who has it

The owner of a project prepared with `playbook-wiki`, and the person who leads each work.

## Where the idea comes from

Three ideas the owner brought on 2026-11-19, kept as concepts:

- An orchestrator that does not code: it reads what must be built, hands each task to an isolated executing agent, checks the result, and calls a person only when needed. Trust rests on four levels: the code, static checks and tests, rule files, and human review.
- Learning by repetition: a correction that repeats, from memory, review, or lint, becomes a proposal to move the lesson down those levels, from memory to a rule, and from a rule to a check.
- Approval by risk, as the Claude Code team describes its review (https://claude.com/resources/webinars/how-the-claude-code-team-does-code-review, with details from secondary sources): low risk needs no human once automated checks pass, medium one person, high two; the risk is set by the change, not by its author; an agent's approval never fills a human's place.

The owner's framing: a kitchen, where the chef tastes every dish, against a factory, where the standard is set once and a person appears only for exceptions. The work looks for the middle and a way to detect it.

## Decided

- R6 becomes: "R6. Only the owner decides, per case or by a recorded delegation. Every statement is Decided, Proposed, or Open; outside a delegation, a missing definition is asked, never invented." 28 words, 9 more than today; delegation-2 makes room (delegation-3).
- R10 becomes: "R10. Deliver in stages; each unit is accepted by its evidence unless the plan marks it judgement." (delegation-4).
- Never delegated: a new definition of the product; push and merge into the main branch; any action outside the repository or on the owner's machine; spending beyond a written ceiling (delegation-5).
- At the close of each work the agent measures how the owner answered each kind of question in the project, and proposes once a delegation for a kind with at least 10 answers, at least 80% accepted as is, and no "no" (delegation-6). The measurement of [measurements.md](measurements.md) is its first data.
- A delegation is a row of the decisions of the work where the owner records it, scoped to one kind of question in that project, revoked by a later decision; a "yes but" or a "no" to a decision taken under it makes the agent propose revoking it (delegation-7).

## Proposed

- Read by the agent: since a work's decisions are history once it closes, the delegations in force are listed in one shared page, such as `01-product/delegations.md`, each citing the decision that made it. Settled in stage 2.
- Within a delegation the agent acts, records the decision citing the delegation, and tells the owner in one line.
- How the measurement runs at each close: a shell script of `playbook-wiki` counts the rows of the project's `decisions.md` by kind and by answer, and prints only the kinds that qualify; the agent reads that output and proposes. The agent does not read the rows itself. Settled in stage 2.

## What the work must not do

- Let the agent delegate to itself: only the owner records a delegation (R6).
- Delegate a new definition of the product by default.

## Later

- The orchestrator and isolated executing agents.
- Approval by levels of risk with more than one person.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Covered: the owner records delegations, the agent acts within them |
| Main flows | Covered: proposed (delegation-6), kept and revoked (delegation-7) |
| What it must do | Covered: R6 and R10 (delegation-3, delegation-4) |
| What it must not do, and what waits | Covered (delegation-5) |
| Qualities: a record of who did what | Partly: how a delegated decision is recorded (delegation-Q6) |
| Limits | Covered: L1 and L4 of delegation-2 |
| Outside systems | Does not apply |
| Volume | Does not apply |
| Who runs and maintains it | Covered: the owner of each project |
| Business rules, states, vocabulary | Partly: "delegation" enters the glossary at the close |
