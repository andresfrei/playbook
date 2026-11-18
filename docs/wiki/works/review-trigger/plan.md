# Plan of review-trigger

Stage 5. The units that answer [definition.md](definition.md) with the technology of [technology.md](technology.md). Accepted by the owner (review-trigger-13).

## Progress

| ID | Status | Evidence | Done on | Owner's words |
|----|--------|----------|---------|---------------|
| review-trigger-U1 | Done | `plugins/playbook-agents/hooks/review-before-commit.sh`, `review-ran.sh`, `hook-lib.sh`, and `hooks.json`; 38 cases `hold:` and 7 cases `hooks:` of `playbook-agents` in `scripts/verify_test.sh`. On 2026-11-18: `sh scripts/verify_test.sh` prints "all cases passed" (489 cases); `bash scripts/verify.sh` exits 0; `claude plugin validate plugins/playbook-agents` passes; shellcheck is clean. The agent `review` read it three times; its findings were fixed, two by review-trigger-14 and -15 | 2026-11-18 | si |
| review-trigger-U2 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| review-trigger-U1 | The two hooks | `plugins/playbook-agents/hooks/review-ran.sh`, `plugins/playbook-agents/hooks/review-before-commit.sh`, both registered in `plugins/playbook-agents/hooks/hooks.json`, and their cases in `scripts/verify_test.sh` (N4 to N9) | The cases show: a commit with no mark is held once, with R20 and `git status --short`; the same command on the same `HEAD` then runs; a commit after a mark runs, and the mark is used up once `HEAD` moves (review-trigger-15); a commit of `docs/wiki/` alone runs (review-trigger-14); a mark is written only for `playbook-agents:review`; bad input, a missing file, or no `CLAUDE_PLUGIN_DATA` prints nothing and exits 0. `bash scripts/verify.sh` and `sh scripts/verify_test.sh` exit 0; `claude plugin validate plugins/playbook-agents` passes; the agent `review` has read the change (R20) | Judgement: it changes what every project that installs `playbook-agents` sees at each commit |
| review-trigger-U2 | The trial | One session of `claude -p` with the plugin from this branch, isolated as review-evidence-10 did, when the owner asks, under a ceiling of USD 2: the agent edits a file and commits, calls `review`, and commits again | Its stream shows: the first commit held with the reminder; the mark written after `review` finished, so SubagentStop runs from a plugin; the commit after it run; whether `session_id` is the same inside the subagent. Recorded in `measurements.md` | Evidence |

Order: U2 runs the hooks U1 builds.

## How a unit is delivered

Decided (review-trigger-12), as this repository delivered review-evidence (review-evidence-15): the units are built on this work's branch, `feat/review-trigger`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). U2 is paid, so it runs only when the owner asks, under its ceiling (review-trigger-5).

## Left out

- The count again of N10: after the release, once the sessions with the hook hold at least 10 risky commits (review-trigger-11).
- A change to what `review` or `review-change` does (review-trigger-5).
- review-evidence-Q5, how `review-change` reports a page left on an old definition.
