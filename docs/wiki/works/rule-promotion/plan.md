# Plan of the work rule-promotion

Decided (rule-promotion-10).

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| rule-promotion-U1 | Done | `sh scripts/verify_test.sh` passes; each break of `evidence.sh` in a copy fails its case | 2026-11-20 | |
| rule-promotion-U2 | Done | `sh scripts/verify.sh`, `python3 codex/test_install.py`, `sh scripts/verify_test.sh`, `check-wiki` pass | 2026-11-21 | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| rule-promotion-U1 | Counting a graduated kind | `evidence.sh check` accepts a Source `graduated to <path>`; `count` prints `revise graduated step: <kind> → <path>` at the threshold for such a kind (N4) | `plugins/playbook-agents/evidence.sh`, `scripts/verify_test.sh` | A pass and a fail case for each; each broken in a copy fails its case; `sh scripts/verify_test.sh` passes | none | Evidence |
| rule-promotion-U2 | The graduation step | Step 8 of `references/evidence.md` of `prepare-project` (N2, N3, N5, N6), and its Codex copy when packaged | `plugins/playbook-wiki/skills/prepare-project/references/evidence.md`, `codex/` | `sh scripts/verify.sh`, `python3 codex/test_install.py`, and `check-wiki` pass; the `review` agent finds no defect left | U1 | Evidence |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | rule-promotion-U1 | no |
| 2 | rule-promotion-U2 | no |

- Most `write` agents at once: 1.
- Worktree preparation: none.

## How the work is delivered

Each unit is a commit on `feat/rule-promotion`, tested nowhere apart. One pull request to `main`, which the owner merges. At the close of this work, the new step runs for the first time: the owner decides each of the six candidates.

## Left out

- Graduating rules of a project other than the playbook (rule-promotion-7).
