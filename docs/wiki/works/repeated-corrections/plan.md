# Plan of the work repeated-corrections

The units that build [architecture.md](architecture.md), in order. Each one is accepted by its evidence unless the table says judgement.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| repeated-corrections-U1 | Not started | | | |
| repeated-corrections-U2 | Not started | | | |
| repeated-corrections-U3 | Not started | | | |
| repeated-corrections-U4 | Not started | | | |
| repeated-corrections-U5 | Not started | | | |

## Units

| ID | Unit | What it delivers | When it ends | Accepted by |
|----|------|------------------|--------------|-------------|
| repeated-corrections-U1 | The page and its script | `evidence.sh` in `playbook-agents`, with `check`, `count`, and `rules`; the format of `docs/wiki/evidence.md`; an empty `evidence-rules.md`; the page listed in `format.md` as an optional file a tool keeps (N4, N5) | `scripts/verify_test.sh` passes cases for: a page that fails the check; one review with the same kind twice counted once; 3 distinct reviews at one level reported; `rules` printing only level 2 and up, from the page and `evidence-rules.md`; no page, no output. Each new case is seen to fail with the code broken | Evidence |
| repeated-corrections-U2 | Rules at the start of `write` and `review` | A `SubagentStart` hook of `playbook-agents`, matcher `^playbook-agents:(write\|review)$`, printing `evidence.sh rules` as `additionalContext` (N1) | Tests pass for: the JSON shape, no output with no rules, no output for another agent, the matcher in `hooks.json` | Evidence |
| repeated-corrections-U3 | The classifier | The agent `classify` (`sonnet` in `models.conf`), the skill `classify-evidence` with the criteria of repeated-corrections-11 and two evaluation cases, and `review` given the tool `Agent` and the step to start `classify` when it has findings (N3) | `scripts/verify.sh` passes (sizes, front matter); the two evaluation cases run and their results are recorded | Judgement: the criteria are a definition's text |
| repeated-corrections-U4 | The check at the end of `review` | `review-ran.sh` also stops a review whose last message lacks "No findings." and whose transcript started no `playbook-agents:classify`, asking for it (N2) | Tests pass for: findings and no classifier blocks; "No findings." passes; a classifier started passes; a missing transcript passes. A real session shows a review starting `classify` and a row added to the page | Evidence |
| repeated-corrections-U5 | Proposals at the close of a work | A step at the close of a work in `prepare-project`: `evidence.sh count`, then each consolidation proposed to the owner, or made by the agent when the kind `consolidate` is delegated (repeated-corrections-13) | The reference file names the step within L2; `check-wiki.sh` passes; the step is followed at the close of this work | Evidence |

Units in order: each depends on the one before it.

## How the work is delivered

As in the works before it (version-check-14), from this repository's history (`git log --merges --first-parent main`: each work reaches `main` by one pull request from its own branch) and its only long-lived branch, `main`, which is production:

- Tested nowhere apart: the tests and checks of each unit, and the real session of U4.
- The units are built in order, one at a time, on this work's branch.
- The branch is renamed from `docs/repeated-corrections` to `feat/repeated-corrections`, since the work now changes code; it has not been pushed.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Steps other than `write` and `review`, memory and lint as sources (repeated-corrections-2, -14).
- The tool that seeds a repository from its past reviews (repeated-corrections-8): a later work, with the extraction fixed to read background results and keep dates.
- The version: at the close, `CLAUDE.md` asks for it. It adds hooks and an agent and breaks nothing, a MINOR by TD22.
