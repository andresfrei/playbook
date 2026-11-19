# Plan of delegation

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide. Accepted (delegation-15).

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| delegation-U1 | Done | R6 and R10 of `plugins/playbook-wiki/contract.md` hold the texts of delegation-3 and delegation-4 word for word; the contract has 253 words. `scripts/verify.sh`: L1 270 and L4 370 for `playbook-wiki`; its tests moved to 271/270 and 370 words. Run on 2026-11-19: `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 341 words at session start, limit 370; playbook-agents loads 615, limit 620"; `sh scripts/verify_test.sh` printed "all cases passed"; `shellcheck` passed. The agent `review` read it and found one fault, fixed: `01-product/rules.md` did not cite delegation-3 and delegation-4 | 2026-11-19 | |
| delegation-U2 | Done | `plugins/playbook-wiki/format.md` at format 5: Kind and Answer as the last two columns, their lists, one space then "(estimated)", plain text, at most eight columns, and `01-product/delegations.md`. `check-wiki.sh` at format 5 refuses a value outside the lists, a bad suffix, and a ninth column; six-column rows and empty cells pass. Eight eval fixtures under `plugins/playbook-wiki/evals/` moved to format 5, each checked with `check-wiki.sh`. Run on 2026-11-19: `shellcheck` passed; `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 341 words at session start, limit 370; playbook-agents loads 615, limit 620"; `sh scripts/verify_test.sh` printed "all cases passed". The agent `review` found five faults, all fixed: fixtures left at format 4, no test of an estimated Kind, a percentage rounded up, loose suffix and column count, a gate test that no longer tested "above" | 2026-11-19 | |
| delegation-U3 | Done | `check-wiki.sh --delegations` counts, for each kind, the rows with an answer other than empty or delegated, estimated ones included, and prints a kind with at least 10, at least 80% as recommended, and none rejected, rounded down; nothing otherwise. Tests cover each threshold at and past its edge, estimated and empty cells, rows across works, and a wiki with no works. Same runs and review as delegation-U2 | 2026-11-19 | |
| delegation-U4 | Built | `plugins/playbook-wiki/skills/doctor/references/format-5.md`, linked from the doctor's `SKILL.md`. Run on 2026-11-19: `bash scripts/verify.sh` passed. The agent `review` found no failing case in it | | |
| delegation-U5 | Built | `plugins/playbook-wiki/skills/prepare-project/references/delegation.md`; `SKILL.md` rules and steps 6 and 7 (698 words, limit 700); the first item of the close in `references/6-execution.md`; in `format.md`, a revoked delegation moves to a table of delegations revoked. Run on 2026-11-19: `bash scripts/verify.sh` passed. The agent `review` found six faults, all fixed: the close proposed never-delegated kinds, a revocation took effect only at the close, delegations in force or declined were proposed again, a delegated stage close still waited for the owner, Kind and Answer in the decider's language, and the order of the close | | |
| delegation-U6 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| delegation-U1 | The contract and its limits | R6 and R10 in `plugins/playbook-wiki/contract.md` with the texts of delegation-3 and delegation-4; L1 270 and L4 370 for `playbook-wiki` in `scripts/verify.sh` and `docs/wiki/01-product/style-guide.md` (delegation-2) | `bash scripts/verify.sh` passes, and the contract holds both texts word for word and at most 270 words | Evidence: the texts are already decided word for word |
| delegation-U2 | Format 5 and the check | `plugins/playbook-wiki/format.md` with the columns Kind and Answer at the end of a work's decisions and the page `01-product/delegations.md`; `check-wiki.sh` at format 5, failing on a value of Kind or Answer outside the lists of N2 and N3, an empty cell allowed (N1 to N3, N5, N8) | The tests of the check pass, with a case for each value accepted and refused; `shellcheck` and `bash scripts/verify.sh` pass | Evidence |
| delegation-U3 | The measurement | The mode `check-wiki.sh --delegations`: for each kind, the rows of every work with an Answer that is not empty, and one line for each kind with at least 10 of them, at least 80% `as recommended` and no `rejected`; nothing when none qualifies (delegation-6, N4) | The tests of the check pass, with a wiki where a kind qualifies, one where it falls short of each condition, and one with estimated and empty cells | Evidence |
| delegation-U4 | The doctor to format 5 | `plugins/playbook-wiki/skills/doctor/references/format-5.md`: add the two columns to every work's `decisions.md`, fill the earlier rows as delegation-9 says, never touch `docs/wiki/decisions.md` (N8) | `bash scripts/verify.sh` passes; the agent `review` read it | Judgement: how the agent estimates is a text a check cannot judge |
| delegation-U5 | Delegation in `prepare-project` | Its rules and its references: record Kind and Answer with each decision; read `01-product/delegations.md` before asking a question of a delegated kind, and within one act, record `agent, by <delegation>`, and tell the owner in one line; never delegate what delegation-5 lists; at the close of a work, run `--delegations` and propose what it prints, and propose revoking on a "yes but" or a "no" (delegation-6, delegation-7, N6, N7) | `bash scripts/verify.sh` passes within L2; the agent `review` read it | Judgement: it is the text of a definition |
| delegation-U6 | This wiki at format 5 | The doctor run on this repository's wiki, the pilot as in earlier formats: the columns in every work, earlier rows filled and marked estimated; `wiki-format.sh mark` writes format 5 | `wiki-format.sh mark docs/wiki` prints "marked docs/wiki as wiki format 5", and `check-wiki.sh --delegations docs/wiki` runs | Evidence |

The agent `review` reads U1 to U5 before delivery: the contract, the format, the check, and the skills reach every project (R20).

## How a unit is delivered

Decided (delegation-15), from this repository's history (`git log --merges --first-parent main`: each work reaches `main` by one pull request from its own branch, as `feat/work-delivery` in #26) and its only long-lived branch, `main`, which is production:

- The work is tested nowhere apart: the checks of each unit, and U6, which runs the doctor on this repository's wiki.
- The units are built in order, one at a time, on this work's branch. U3 reads the format of U2; U4, U5, and U6 read U2 and U3.
- The branch is renamed from `docs/delegation` to `feat/delegation`, since the work now changes code; it has not been pushed.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- A fix to the check for an empty work `README.md`, found on 2026-11-19: a small change of its own.
- Evaluation cases for the new steps of `prepare-project`: the wiki did not decide them.
- The work `version-check` ([definition.md](definition.md), Later).
- The version: when the work closes, `CLAUDE.md` asks for it (github-release-2). Format 5 makes it MAJOR by TD22.
