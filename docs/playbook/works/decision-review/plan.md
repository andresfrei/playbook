# Plan of the work decision-review

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| decision-review-U1 | Done | All 241 decisions classed (158 Valid, 69 replaced, 11 outdated, 3 doubtful); every finding read by the main session; 79 are history replaced by design (`format.md`, line 36), 4 rows go to the owner in `report.md`; agents on haiku by the owner's choice | 2026-11-20 | |
| decision-review-U2 | Done | Every row of `report.md` answered: R1 by decision-review-9, R2 to R4 by -11 to -13; `CLAUDE.md`, `docs/wiki/README.md`, and `01-product/phase-4.md` follow the answers; `check-wiki` passes | 2026-11-20 | "Reescribir (Recomendado)"; "Sí, las tres así (Recomendado)" |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| decision-review-U1 | The classification | `report.md`: the count per class, and one row per decision that is not Valid, with its class, evidence, and a recommendation. Five `explore` agents run at once, one per range: D1–D55, D56–D110, D111–D160, D161–D208, TD1–TD33. The main session verifies each row by reading its evidence | `docs/wiki/works/decision-review/report.md` | Every decision has a class; every row that is not Valid has evidence the main session read; no other file changed | none | Evidence |
| decision-review-U2 | The owner's answers | One decision per row of the report: replace, mark as replaced, or confirm. At the close, `docs/wiki/decisions.md` and the shared pages follow the answers | `docs/wiki/works/decision-review/decisions.md`, then `docs/wiki/decisions.md` and the shared pages the answers name | Every row of the report has the owner's answer; `check-wiki` passes | U1 | Judgement: the owner answers each row |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | decision-review-U1 | no |
| 2 | decision-review-U2 | no |

- Most `write` agents at once: 0. U1 uses five read-only `explore` agents.
- Worktree preparation: none.

## How the work is delivered

Decided (decision-review-7), as readme-redesign-13: commits on `docs/decision-review`; one pull request to `main`, which the owner merges.

## Left out

- Changing code: an answer that needs code becomes a work or a fix of its own.
- The decisions inside `works/` (decision-review-2).
