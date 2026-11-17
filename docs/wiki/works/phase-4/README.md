# Work phase-4

Phase 4 of the product (D167): version 2, which splits the product into a shared core, `playbook-wiki`, and the owner's agent system, `playbook-agents`, and removes the support for opencode (TD32, D191). Andres Frei leads it.

Status: Open.

Its decisions up to D208 are in [../../decisions.md](../../decisions.md). New ones are `phase-4-1` onwards, in its own `decisions.md`.

## Where work stands

Updated 2026-11-16, after phase-4-2.

Stage 6, Execution, is open. Stages 1 to 5 are closed (D197). U28 to U40 and U42 are done: [../../05-plan/plan-phase-4.md](../../05-plan/plan-phase-4.md). U42, added by phase-4-1, is built before the pull request.

Waiting for the owner:

- The push of `v2` and its pull request into `main`, then the tag `v2.0.0` (TD22, D196, D208).
- Q61, for the release after version 2: [../../01-product/open-questions.md](../../01-product/open-questions.md).

Next steps:

1. The owner merges the pull request of `v2` into `main`.
2. U41, on the owner's machine, when the owner asks for it.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-16 |
| 2 Technology | Closed | 2026-11-16 |
| 3 Skills | Closed | 2026-11-16 |
| 4 Design system | Closed, not applicable (D195) | 2026-11-16 |
| 5 Plan | Closed | 2026-11-16 |
| 6 Execution | Open | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [../../01-product/phase-4.md](../../01-product/phase-4.md) | The product definition for phase 4, a shared core separate from each person's agent system: what is decided, proposed, and open | |
| [../../03-technology/phase-4.md](../../03-technology/phase-4.md) | What phase 4 needs from its technology, needs N16 to N27, and what is chosen for each (stage 2 of phase 4) | `plugins/playbook-wiki/format.md`, `plugins/playbook-wiki/merge-step.sh`, `plugins/playbook-wiki/hooks/merge-step-hook.sh` |
| [../../03-technology/architecture-phase-4.md](../../03-technology/architecture-phase-4.md) | The architecture of phase 4: three plugins, the start command with its wizard, and the files of a work, with risks, trade-offs, and how it can evolve | |
| [../../05-plan/plan-phase-4.md](../../05-plan/plan-phase-4.md) | The work plan for phase 4: units U28 to U42 (stage 5 of phase 4) | |
| [decisions.md](decisions.md) | The decisions of this work written at format 4, from phase-4-1 | |
