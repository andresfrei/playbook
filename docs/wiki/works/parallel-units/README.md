# Work parallel-units

After the plan of a work is accepted, a step organizes its units into batches that several `write` agents can build at the same time, so a work takes less time without units stepping on each other. Andres Frei leads it.

Status: Open.

## Where work stands

Updated 2026-11-20, after parallel-units-10.

Stage 1, Wiki, is closed (parallel-units-10). Stage 2, Technology, is open.

Waiting for a decision: none.

Next steps, in order:

1. Check what Claude Code offers for worktrees: running `write` in its own worktree, copying ignored files such as `.env` into it, and how the review hold behaves across worktrees (parallel-units-9).
2. Write the work's technology and architecture pages.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Open | |
| 3 Skills | Not started | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [definition.md](definition.md) | The problem, an example, what is known, and the coverage of each topic | |
| [questions.md](questions.md) | The open questions | |
| [decisions.md](decisions.md) | The decisions of this work | |
