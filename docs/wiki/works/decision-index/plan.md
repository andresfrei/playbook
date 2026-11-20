# Plan of the work decision-index

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| decision-index-U1 | Not started | | | |
| decision-index-U2 | Not started | | | |
| decision-index-U3 | Not started | | | |
| decision-index-U4 | Not started | | | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| decision-index-U1 | Format 6 and the check | The column Replaces and the history work in `format.md`; the check of Replaces and `--decisions --in-force`; every rule for an older format removed | `plugins/playbook-wiki/format.md`, `plugins/playbook-wiki/check-wiki.sh`, `scripts/verify_test.sh` | Each new rule has a passing and a failing case; `sh scripts/verify_test.sh` and `sh scripts/verify.sh` pass | none | Evidence |
| decision-index-U2 | `migrate` | `doctor` renamed `migrate`: steps for an agent to rewrite any older wiki to the current format from `format.md`, its references of formats 2 to 5 deleted (decision-index-10); the notice and the skills that write a wiki stop and point to it | `plugins/playbook-wiki/skills/doctor/` moved to `skills/migrate/`, `plugins/playbook-wiki/hooks/`, `plugins/playbook-wiki/skills/init/`, `plugins/playbook-wiki/skills/prepare-project/`, `plugins/playbook-wiki/skills/write-docs/`, `plugins/playbook-wiki/README.md`, `plugins/playbook-wiki/skeleton.md`, `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/review-evidence/`, `scripts/verify_test.sh`, `docs/claude-code.md` | No `doctor` left outside `docs/wiki/`; `claude plugin validate plugins/playbook-wiki` and the tests pass | U1 | Evidence |
| decision-index-U3 | The Codex copy | `codex/` follows U1 and U2 | `codex/` | `python3 codex/test_install.py` passes | U2 | Evidence |
| decision-index-U4 | This wiki in format 6 | This repository's wiki migrated with `migrate`, the history as `works/history/`, and `README.md`, `CLAUDE.md` following | `docs/wiki/`, `CLAUDE.md` | `check-wiki` passes at format 6; every `(estimated)` Replaces is listed for the owner | U2 | Judgement: the owner reads the estimated Replaces |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | decision-index-U1 | no |
| 2 | decision-index-U2 | no |
| 3 | decision-index-U3, decision-index-U4 | no |

- Most `write` agents at once: 1. U1 to U3 are built by `write`, one at a time, since U1 and U2 share `scripts/verify_test.sh`; U4 is run in the main session.
- Worktree preparation: none.

## How the work is delivered

Decided (decision-index-11), as readme-redesign-13: each unit is a commit on `feat/decision-index`; one pull request to `main`, which the owner merges; then the release 4.0.0 (decision-index-3).

## Left out

- `rule-promotion`, which waits for this work.
