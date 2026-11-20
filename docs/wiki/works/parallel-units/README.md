# Work parallel-units

After the plan of a work is accepted, a step organizes its units into batches that several `write` agents can build at the same time, so a work takes less time without units stepping on each other. Andres Frei leads it.

Status: Open.

## Where work stands

Updated 2026-11-20, after parallel-units-20.

Stages 1 to 5 are closed. Stage 6, Execution, is open: batch 1, U1 and U2, is being built in parallel; see [plan.md](plan.md).

Waiting for a decision: none.

Next steps, in order:

1. Merge U1 and U2 into `feat/parallel-units` when their checks pass, after `review`.
2. The owner reviews U1 and U2.
3. Close the work.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Closed | 2026-11-20 |
| 3 Skills | Closed | 2026-11-20 |
| 4 Design system | Closed (not applicable) | 2026-11-20 |
| 5 Plan | Closed | 2026-11-20 |
| 6 Execution | Open | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [definition.md](definition.md) | The problem, an example, what is known, and the coverage of each topic | |
| [questions.md](questions.md) | The open questions | |
| [technology.md](technology.md) | What the work needs from its technology, and the answers | |
| [architecture.md](architecture.md) | The shape, modules, data, and risks | |
| [skills.md](skills.md) | The skills used to build the work | |
| [plan.md](plan.md) | The units, the batches, and how the work is delivered | |
| [decisions.md](decisions.md) | The decisions of this work | |
