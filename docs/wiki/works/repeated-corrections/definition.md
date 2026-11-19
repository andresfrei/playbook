# Definition of the work repeated-corrections

What this work must make true: a mistake that the agent `review` keeps finding becomes something the agent keeps in mind at the step where it happens, and, when that is not enough, something stronger, without anyone counting by hand (repeated-corrections-1).

## The problem

The same correction is made by hand again and again, and nothing notices it repeats. On 2026-11-19, in the work `version-check`, `review` found tests that passed with the behaviour broken in two units in a row (version-check-U1 and version-check-U2), though R11 already asks for tests with each change. Each time the finding was fixed and forgotten.

Today the findings of `review` are kept only in the session and, for the last two works, as one line of evidence in `plan.md`. Engram keeps lessons, but on one machine, with no type and no count.

Where the idea comes from: the owner's "learning by repetition", one of three ideas of 2026-11-19 recorded in [../delegation/definition.md](../delegation/definition.md). The work `delegation` built the side of answers (repeated answers become a delegation); this work builds the side of corrections.

## Who has it

The owner, who reads the same finding again; the agent, which repeats the mistake; every project with `playbook-agents`, whose `review` produces the findings.

## The shape

- Source: the findings of `review`, each with its failing case (repeated-corrections-2).
- What is learned is a thing to keep in mind at its step, not a rule loaded always; a check when it keeps repeating and the mistake can be found mechanically (repeated-corrections-3).
- A tool that hooks call, to query before a step and to pass the evidence of a finding; its data in the repository (repeated-corrections-4).
- Consolidation by level: N records of the same thing at level k become one rule at level k+1 and are deleted, git keeping them; the level counts the consolidations a problem resisted (repeated-corrections-5). For example, three findings of tests that pass with the code broken, at level 1, become one rule at level 2: "break the code on purpose to check each new test fails". If the mistake comes back, it is recorded at level 2.
- The agent keeps the records and the index of types; a script counts (repeated-corrections-6).
- A skill of criteria keeps the judgement the same (repeated-corrections-7).

## The measurement

Before anything is built: read the findings of `review` in the transcripts on the owner's machine, group them by type, and count how many repeat. If corrections rarely repeat, the work stops (repeated-corrections-1). Written in `measurements.md` when made.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Partly covered: who approves a consolidation (repeated-corrections-Q1) |
| Main flows | Partly covered: the steps that query the tool (repeated-corrections-Q3) |
| What it must do | Partly covered: the threshold N (repeated-corrections-Q2) |
| What it must not do, and what waits | Partly covered: memory and lint wait (repeated-corrections-2) |
| Qualities: a record of who did what | Covered: each rule cites what it consolidated; git keeps the deleted records (repeated-corrections-5) |
| Limits | Covered: hooks in POSIX shell, as the plugins' hooks; skills within L2 |
| Outside systems | Does not apply |
| Volume | Partly covered: the measurement |
| Who runs and maintains it | Covered: the agent keeps the records, a script counts (repeated-corrections-6) |
| Business rules, states, vocabulary | Partly covered: where the records live (repeated-corrections-Q4) |
