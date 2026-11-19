# Definition of the work seed-evidence

What this work must make true: in a repository that already had reviews, the person runs one command and gets a first `docs/wiki/evidence.md` built from those past reviews, without stale findings and without writing anything they did not see (seed-evidence-1).

## The problem

The work `repeated-corrections` (3.2.0) stores the findings of each new review as evidence. A repository starts with an empty page, though its past reviews are kept in the person's transcripts under `~/.claude/projects/`: 232 distinct reviews in six projects on 2026-11-19 (see [../repeated-corrections/measurements.md](../repeated-corrections/measurements.md)). The owner asked for this tool when the idea was shaped (repeated-corrections-8).

## Who has it

A person with the playbook who has reviewed changes in a repository before installing 3.2.0, and wants its rules from the start.

## What is known

- `classify` already stores the findings of one review, given the findings, the tree root, and a review identifier (repeated-corrections-17, -27).
- The extraction of the measurement read the start of reviews in the background, not their result, and kept no dates (repeated-corrections measurements, "Limits").
- A finding from months ago may be fixed already; seeding it adds noise (repeated-corrections-8).
- The page belongs to the target repository; writing there is an action outside the playbook, decided for each repository by its owner.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Open: how the tool is started (seed-evidence-Q1) |
| Main flows | Open: preview before writing (seed-evidence-Q2) |
| What it must do | Open: which reviews it takes (seed-evidence-Q3) |
| What it must not do, and what waits | Partly covered: it writes only the evidence page of the repository where it runs |
| Qualities | Open: cost (seed-evidence-Q4) |
| Limits | Covered: the transcripts exist only on the person's machine |
| Outside systems | Does not apply |
| Volume | Open: the measurement of reviews per repository and age |
| Who runs and maintains it | Covered: the person, once per repository |
| Business rules, states, vocabulary | Covered: the vocabulary of repeated-corrections |
