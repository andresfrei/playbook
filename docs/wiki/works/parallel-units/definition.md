# Definition of the work parallel-units

What this work must make true: when a work's plan is accepted, it already says which units are built together, in batches, what each unit may change, and how the units of a batch reach the work's branch, so stage 6 sends several `write` agents at once without them stepping on each other (parallel-units-1, parallel-units-2).

## The problem

Stage 5 asks one yes or no question: "whether units that do not depend on each other may be built in parallel" (`plugins/playbook-wiki/skills/prepare-project/references/5-plan.md`, step 5). The plan then lists "which units may be built together" (step 6), and stage 6 takes them together (`6-execution.md`, step 1). R21 already says that `write` builds units in parallel and gets the exact paths it may change.

Nothing says:

- how the units are grouped: which ones go together, and which wait for which;
- what each unit may change, so two agents do not edit the same file;
- where each agent works, and how its result reaches the work's branch;
- when the next group starts.

So the agent builds units one by one, and a work takes longer than it needs.

## An example

The owner confirmed this picture (parallel-units-2). In the work ask-before-irreversible:

| Batch | Units | Why |
|-------|-------|-----|
| 1 | U1 (the delivery hook) and U2 (`protect.sh`), one `write` each, at the same time | Neither depends on the other |
| 2 | U3 (the command `protect`) | It runs `protect.sh`, so it waits for U2 |

U1 and U2 both changed `scripts/verify_test.sh`. The batch has to say how two agents avoid each other on a shared file: exclusive paths, or a worktree per agent with the results merged into the work's branch, each unit read by `review` before it enters.

## Who has it

A person who prepares a work with `prepare-project` and lets the agent build its plan, in this repository or in any project that uses `playbook-wiki`.

## What is known

- Claude Code's Agent tool can run a subagent in its own git worktree (`isolation: "worktree"`), which is removed when the agent changes nothing. Several agents can be started in one message and run at the same time. Read in the tool's description in this session, on 2026-11-20.
- `playbook-agents` has a hook that holds the first `git commit` of a session once until `review` has run (`hooks/review-before-commit.sh`); its mark is kept per session.
- The plan's units are ordered by what each depends on (`5-plan.md`, step 4).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Covered: the owner accepts the plan with its batches; the agent builds them |
| Main flows | Partly: where the batches are decided is parallel-units-Q1 |
| What it must do | Partly: how agents avoid each other is parallel-units-Q2; how a unit reaches the work's branch is parallel-units-Q3 |
| What it must not do, and what waits | Partly: when the next batch starts is parallel-units-Q4 |
| Qualities | Covered: no two agents change the same file at the same time |
| Limits | Partly: how many agents run at once is parallel-units-Q5 |
| Outside systems | Covered: git worktrees and Claude Code's Agent tool |
| Volume | Does not apply |
| Who runs and maintains it | Covered: it ships in `playbook-wiki`, in `prepare-project` |
| Business rules, states, vocabulary | Covered: a batch is a group of units built at the same time; the word is new to the glossary |
