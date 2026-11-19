# Work repeated-corrections

Turns a correction that repeats into something the agent keeps in mind at the step where it happens, consolidated by level when it keeps repeating. Andres Frei leads it.

Status: Closed on 2026-11-19 (repeated-corrections-30).

## Where work stands

Updated 2026-11-19, after repeated-corrections-30.

The work is closed: repeated-corrections-U1 to U5 are Done (see [plan.md](plan.md)), and the shared pages say what it decided (`03-technology/architecture.md`, `04-skills/working-skills.md`, `01-product/glossary.md`, `01-product/delegations.md`, `01-product/overview.md`, `01-product/skill-set.md`). `--delegations` proposed open-work, delegated narrowly (repeated-corrections-29). No decision reached `main` since the work started, so the step at the merge has nothing to compare.

PR #34 merged into `main` on 2026-11-19 at f54cd6c. Version 3.2.0 is set in the three manifests and released as `v3.2.0` (repeated-corrections-30).

After the release: the check of the classifier blocks a review once per subagent, as `stop_hook_active` was not set on repeated stops (repeated-corrections-31), for 3.2.1.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-19 |
| 2 Technology | Closed | 2026-11-19 |
| 3 Skills | Closed | 2026-11-19 |
| 4 Design system | Closed, not applicable | 2026-11-19 |
| 5 Plan | Closed | 2026-11-19 |
| 6 Execution | Closed | 2026-11-19 |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [definition.md](definition.md) | The problem, the shape, the measurement, and the coverage of each topic | |
| [plan.md](plan.md) | The units and how the work is delivered | |
| [skills.md](skills.md) | The skills used to build the work | |
| [architecture.md](architecture.md) | The shape, modules, data, risks, and trade-offs | |
| [technology.md](technology.md) | The needs of the work and what answers each | |
| [measurements.md](measurements.md) | How often the findings of `review` repeat, from a sample of 60 reports | |
| [decisions.md](decisions.md) | The decisions of this work | |
| [questions.md](questions.md) | The open questions | |
