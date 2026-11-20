# Work parallel-units

After the plan of a work is accepted, a step organizes its units into batches that several `write` agents can build at the same time, so a work takes less time without units stepping on each other. Andres Frei leads it.

Status: Closed.

## Where work stands

Updated 2026-11-20, after parallel-units-25.

Stages 1 to 5 are closed (parallel-units-10, -16, -17, -18, -20). Stage 6, Execution, is closed: units U1 and U2 of [plan.md](plan.md) are Done, built in parallel as the work defines, and the shared pages are written. The work closes for version 3.5.0 (parallel-units-25).

Waiting for a decision: none.

Next steps, in order:

1. The owner pushes `feat/parallel-units`, opens the pull request, and merges it (R14).
2. After the merge: version 3.5.0 in the three manifests, the tag `v3.5.0`, and the release on GitHub (parallel-units-25).

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Closed | 2026-11-20 |
| 3 Skills | Closed | 2026-11-20 |
| 4 Design system | Closed (not applicable) | 2026-11-20 |
| 5 Plan | Closed | 2026-11-20 |
| 6 Execution | Closed | 2026-11-20 |

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
