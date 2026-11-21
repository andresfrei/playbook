# Plan of the work decision-index

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| decision-index-U1 | Done | `format.md` at format 6: nine columns with Replaces, in force, the history in `works/history/`, no rule for an older format; `check-wiki.sh` checks Replaces and prints `--decisions --in-force [page]`; a pass and a fail case per rule, each rule broken in a copy to see its case fail; `verify_test.sh` all cases passed, `verify.sh` passed. The history is exempt from the 60-word limit: 89 of its 241 rows exceed it | 2026-11-20 | |
| decision-index-U2 | Done | `doctor` moved to `migrate` with generic steps and no reference of an older format; `prepare-project`, `write-docs`, and `init` stop on an older wiki; evals renamed; no `doctor` left outside `docs/wiki/` but the review-evidence seed, a diff of a past commit; `migrate` 494 words, `prepare-project` 696 after keeping its decided trigger wording; `claude plugin validate`, `verify.sh`, and `verify_test.sh` pass; a broken notice made two cases fail. The new evals were not run | 2026-11-20 | |
| decision-index-U3 | Done | `codex/` packages `migrate` from `skills/migrate/` without the fork, agent, and owner-only keys, and carries `wiki-writer` as steps the session follows, since Codex cannot run a skill in a forked agent; no `doctor` left in `codex/`; `python3 codex/test_install.py` 11 tests OK, with the new `test_package_follows_migrate` | 2026-11-20 | |
| decision-index-U4 | Done | The wiki migrated to format 6 by a sonnet agent following `wiki-writer` and `migrate` (the installed plugin does not carry the agent yet): `docs/wiki/decisions.md` moved to `works/history/`, Replaces added to all 27 works, 49 estimated values cut to 13 entire replacements after decision-index-14; `check-wiki passed: wiki format 6, 27 works`; marker written by `wiki-format.sh mark` | 2026-11-20 | "si" |
| decision-index-U5 | Done | `plugins/playbook-wiki/agents/wiki-writer.md`, sonnet and effort medium, listed by a new headless session; `migrate` runs in it with `context: fork` and stays owner-only (decision-index-13); the close hands shared pages to it; `write-shared-pages` removed and its 5 task rows name `wiki-writer`; `verify.sh` accepts an agent of `playbook-wiki` that sets model and effort; `playbook-wiki` loads 351 of 370 words; `claude plugin validate`, `verify.sh`, and `verify_test.sh` pass | 2026-11-20 | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| decision-index-U1 | Format 6 and the check | The column Replaces and the history work in `format.md`; the check of Replaces and `--decisions --in-force`; every rule for an older format removed | `plugins/playbook-wiki/format.md`, `plugins/playbook-wiki/check-wiki.sh`, `scripts/verify_test.sh` | Each new rule has a passing and a failing case; `sh scripts/verify_test.sh` and `sh scripts/verify.sh` pass | none | Evidence |
| decision-index-U2 | `migrate` | `doctor` renamed `migrate`: steps for an agent to rewrite any older wiki to the current format from `format.md`, its references of formats 2 to 5 deleted (decision-index-10); the notice and the skills that write a wiki stop and point to it | `plugins/playbook-wiki/skills/doctor/` moved to `skills/migrate/`, `plugins/playbook-wiki/hooks/`, `plugins/playbook-wiki/skills/init/`, `plugins/playbook-wiki/skills/prepare-project/`, `plugins/playbook-wiki/skills/write-docs/`, `plugins/playbook-wiki/README.md`, `plugins/playbook-wiki/skeleton.md`, `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/review-evidence/`, `scripts/verify_test.sh`, `docs/claude-code.md` | No `doctor` left outside `docs/wiki/`; `claude plugin validate plugins/playbook-wiki` and the tests pass | U1 | Evidence |
| decision-index-U3 | The Codex copy | `codex/` follows U1 and U2 | `codex/` | `python3 codex/test_install.py` passes | U2 | Evidence |
| decision-index-U4 | This wiki in format 6 | This repository's wiki migrated with `migrate`, run in `wiki-writer`, the history as `works/history/`, and `README.md`, `CLAUDE.md` following | `docs/wiki/`, `CLAUDE.md` | `check-wiki` passes at format 6; every `(estimated)` Replaces is listed for the owner | U5 | Judgement: the owner reads the estimated Replaces |
| decision-index-U5 | The agent `wiki-writer` | `plugins/playbook-wiki/agents/wiki-writer.md`, sonnet and effort medium (decision-index-12): writes wiki pages from a brief, runs `check-wiki.sh` until it passes, returns the pages changed or what it could not fix; `migrate` runs in it with `context: fork`; the close of `prepare-project` hands the shared pages to it; `.claude/agents/write-shared-pages.md` is removed and `docs/wiki/tasks.md` names `wiki-writer` | `plugins/playbook-wiki/agents/`, `plugins/playbook-wiki/skills/migrate/SKILL.md`, `plugins/playbook-wiki/skills/prepare-project/`, `.claude/agents/write-shared-pages.md`, `docs/wiki/tasks.md`, `scripts/verify.sh`, `scripts/verify_test.sh` | `claude plugin validate plugins/playbook-wiki` passes; `playbook-wiki` stays within 370 words at session start; a new session lists the agent; the tests pass | U2 | Evidence |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | decision-index-U1 | no |
| 2 | decision-index-U2 | no |
| 3 | decision-index-U3, decision-index-U5 | no |
| 4 | decision-index-U4 | no |

- Most `write` agents at once: 1. U1 to U3 and U5 are built by `write`, one at a time, since they share `scripts/verify_test.sh`; U4 runs `migrate` in `wiki-writer` after U5.
- Worktree preparation: none.

## How the work is delivered

Decided (decision-index-11), as readme-redesign-13: each unit is a commit on `feat/decision-index`; one pull request to `main`, which the owner merges; then the release 4.0.0 (decision-index-3).

## Left out

- `rule-promotion`, which waits for this work.
