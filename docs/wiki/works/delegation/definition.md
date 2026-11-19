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

## Proposed

- A delegation is a decision like any other: recorded with the owner's words, scoped to one kind of question in one project, and revoked by a later decision.
- Within a delegation the agent acts, records the decision citing the delegation, and tells the owner in one line.
- A short list of decisions is never delegated (delegation-Q3).
- A decision memory proposes delegations from how the owner answered: the measurement of [measurements.md](measurements.md) is its first data (delegation-Q4).
- R10 is shortened, since a unit accepted by evidence is a delegation (delegation-Q2).

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
| Main flows | Partly: how a delegation is proposed and revoked (delegation-Q4, delegation-Q5) |
| What it must do | Partly: R6 decided (delegation-3); R10 text (delegation-Q2) |
| What it must not do, and what waits | Covered, except the never-delegated list (delegation-Q3) |
| Qualities: a record of who did what | Partly: how a delegated decision is recorded (delegation-Q6) |
| Limits | Covered: L1 and L4 of delegation-2 |
| Outside systems | Does not apply |
| Volume | Does not apply |
| Who runs and maintains it | Covered: the owner of each project |
| Business rules, states, vocabulary | Partly: "delegation" enters the glossary at the close |
