# Plan of review-evidence

Stage 5. The units that answer [definition.md](definition.md) with the technology of [technology.md](technology.md). Accepted by the owner (review-evidence-16).

## Progress

| ID | Status | Evidence | Done on | Owner's words |
|----|--------|----------|---------|---------------|
| review-evidence-U1 | Not started | | | |
| review-evidence-U2 | Not started | | | |
| review-evidence-U3 | Not started | | | |
| review-evidence-U4 | Not started | | | |
| review-evidence-U5 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| review-evidence-U1 | The count for R20 | The transcripts of this repository's sessions read with `jq` on the owner's machine: each `git commit` run by `Bash`, whether a call of `review` or `review-change` came before it in the session, and whether its diff is risky by R20's list, with the item it falls under (N9, review-evidence-4) | The counts are in `measurements.md`, a page of this work: commits, risky commits, risky commits reviewed; no transcript text is copied; nothing paid | Judgement: classing a commit risky is a judgement the owner reviews |
| review-evidence-U2 | The trial | The first seeded diff, its two cases in `plugins/playbook-agents/evals/review-evidence-*/`, and `plugins/playbook-agents/evals/review-evidence-rule.sh`; one run of each of the three reviewers, when the owner asks, after the owner has run `claude setup-token` (N5, N6, N10, review-evidence-10) | The four points under "Not verified" in [technology.md](technology.md) are answered with their evidence, among them the `init` event of the run with the rule, and the cost of one run of each reviewer is recorded in `measurements.md`, a page of this work, with the ceiling proposed for U4 | Evidence |
| review-evidence-U3 | The seeded diffs | The other five seeded diffs and the clean one, one per class of N7, each with its two cases and its row in the script (N5 to N7) | Each `fixture.sh`, run in an empty temporary folder, exits 0 and leaves the commit with its seeded defect, or with none for the clean diff; `bash scripts/verify.sh` exits 0; `claude plugin validate plugins/playbook-agents` passes | Judgement: whether each seeded defect is a fair case of its class |
| review-evidence-U4 | The measurement | Three runs of the fourteen cases and of the seven runs with the rule, when the owner asks, under the ceiling the owner approved (review-evidence-5); each reply read as N8 says | `measurements.md`, a page of this work holds, for each reviewer and diff, each seeded defect found or missed and each other finding real or not, with the line that shows it; and the result of review-evidence-3 for each reviewer: a gap shown or not | Judgement: the owner reviews the table (N8) |
| review-evidence-U5 | The wrapper and the rule | Only when U4 shows that `/code-review` with the rule finds at least what `review` finds (the condition Proposed in [definition.md](definition.md)): `review-change` rewritten as a wrapper that calls `/code-review`; the rule in this repository's `CLAUDE.md` and in `plugins/playbook-wiki/format.md`, beside the two sentences; the cases of `review-change` updated (review-evidence-8) | `bash scripts/verify.sh` exits 0; `claude plugin validate` passes for both plugins; `sh plugins/playbook-wiki/check-wiki.sh docs/wiki` passes; the agent `review` has read the change (R20) | Judgement: it changes the text of a skill and the format of `playbook-wiki` |

Order: U1 costs nothing and depends on nothing, so it goes first. U2 checks what U3 and U4 rely on, with one diff and one run each, before more is built or spent. U3 builds the rest on what U2 showed. U4 measures all of it. U5 depends on the result of U4; when U4 shows no reason, U5 is dropped and the work closes with the measurement.

## How a unit is delivered

Decided (review-evidence-15), as this repository delivered skill-adherence (skill-adherence-15): the units are built on this work's branch, `feat/review-evidence`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). Each paid run happens only when the owner asks, under a ceiling the owner approved (review-evidence-5). U5 changes an interface others use, the skill `review-change` and the format of `playbook-wiki`, so the agent `review` reads it before delivery (R20).

## Left out

- CodeRabbit, and any other outside reviewer: [research.md](research.md) and technology.md discard it.
- A hook that enforces R20 (C4 of research.md): no decision of this work names one; U1 says whether the evidence asks for it, for a later work.
- The other concepts of research.md not named by a decision: a gate by risk, the size of a diff, a separate step that verifies each finding.
- A change to `plugins/playbook-wiki/contract.md`, which also states the two sentences: `/code-review` reads `CLAUDE.md`, not the contract.
