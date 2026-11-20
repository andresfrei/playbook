# Work ask-before-irreversible

Makes Claude Code ask the person before a delivery action that cannot be undone, such as a push, a merge, or a release, so rule R14 is enforced and not only written. Andres Frei leads it.

Status: Open.

## Where work stands

Updated 2026-11-19, after ask-before-irreversible-20.

Stages 1 to 5 are closed; stage 6, Execution, is open. [plan.md](plan.md) holds the units and their progress.

Waiting for a decision: none.

Next steps, in order:

1. Build ask-before-irreversible-U1, the delivery hook.
2. Build U2, the protect script, then U3, the protect command.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-19 |
| 2 Technology | Closed | 2026-11-19 |
| 3 Skills | Closed | 2026-11-19 |
| 4 Design system | Closed (not applicable) | 2026-11-19 |
| 5 Plan | Closed | 2026-11-19 |
| 6 Execution | Open | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [definition.md](definition.md) | The problem, what is known, and the coverage of each topic | |
| [measurements.md](measurements.md) | Whether a hook's `ask` shows a prompt in each permission mode | |
| [technology.md](technology.md) | What the work needs from its technology, and the answers | |
| [architecture.md](architecture.md) | The shape, modules, data, and risks | |
| [skills.md](skills.md) | The skills used to build the work | |
| [plan.md](plan.md) | The units and how the work is delivered | |
| [decisions.md](decisions.md) | The decisions of this work | |
| [questions.md](questions.md) | The open questions | |
