# Plan of skill-triggering

Stage 5. The units that answer [definition.md](definition.md) with the technology of [technology.md](technology.md). Proposed until the owner accepts it.

## Progress

| ID | Status | Evidence | Done on | Owner's words |
|----|--------|----------|---------|---------------|
| skill-triggering-U1 | Not started | | | |
| skill-triggering-U2 | Not started | | | |
| skill-triggering-U3 | Not started | | | |
| skill-triggering-U4 | Not started | | | |
| skill-triggering-U5 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| skill-triggering-U1 | `mark` without `mktemp` | `plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh` keeps the copy of the old marker beside it and deletes it on every exit (N6); a case in `scripts/verify_test.sh` that runs `mark` with a `TMPDIR` that cannot be written. The `review` agent reads the change (R20) | `sh scripts/verify_test.sh` prints "all cases passed" with the new case; `bash scripts/verify.sh` exits 0; `shellcheck` prints nothing; no copy is left in the wiki's folder after a passing or a failing `mark` | Evidence |
| skill-triggering-U2 | First measurement | One run, when the owner asks, of every case of `review-change`, `keep-minimal`, `prepare-project`, and `avoid-generic-design`: `--runs 3`, `--json`, `--keep-temp`, the cases of triggering with `--ablation none`, under `--max-cost-usd 3` per skill (skill-triggering-3, -6). For each run where the skill did not load, what the agent did, read from its trace; for `prepare-project-new-project-stage-one`, whether the skill or the roles check asked the two questions | For each case, the runs that loaded the skill out of 3, the scores of both arms, and the cost, recorded in this table; the owner sets the ceiling of U5 | Evidence |
| skill-triggering-U3 | Descriptions | New words for the description of each of `review-change`, `keep-minimal`, and `prepare-project` that U2 shows below skill-triggering-2, within 250 characters and in the same form (skill-triggering-4). A skill that already meets skill-triggering-2 is not changed | `bash scripts/verify.sh` exits 0; each change is listed with the runs of U2 it answers | Judgement: it changes the text of skills |
| skill-triggering-U4 | Gotchas | A gotcha in `review-change` for skill-best-practices-Q2, in `prepare-project` for -Q3 when U2 shows the skill asks the two questions, and in `avoid-generic-design` for -Q4, each from the trace of U2, within 700 words. When U2 shows the roles check of the contract asks them, the owner is asked before the contract changes | `bash scripts/verify.sh` exits 0; each gotcha cites the run it comes from | Judgement: it changes the text of skills |
| skill-triggering-U5 | Second measurement | The run of U2 again, on the skills U3 or U4 changed, under the ceiling the owner set after U2 | Each case meets skill-triggering-2, and each case of skill-best-practices-Q2 to -Q4 passes its grader in the arm with the plugin; results recorded in this table. A skill that does not is shown to the owner before any further change | Evidence |

Order: U1 depends on nothing and costs nothing. U2 comes before U3 and U4, since no text changes before it is measured (skill-triggering-2). U3 and U4 change different lines of the same skills and are measured together by U5.

## How a unit is delivered

Proposed, read from how this repository delivered its last works (skill-best-practices-9): the five units are built on this work's branch, `feat/skill-triggering`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). U1 changes `wiki-format.sh`, so the `review` agent reads it before it is Done (R20). A paid run of `claude plugin eval` happens only when the owner asks (skill-triggering-3).

## Left out

- A change to the form of a description (skill-triggering-4), unless U5 shows words alone do not reach skill-triggering-2.
- The cases of `write-docs`, `doctor`, and `write-skill`, which no question of this work names.
- The twenty queries per skill that agentskills.io proposes to tune a description, left out by skill-best-practices as well.
