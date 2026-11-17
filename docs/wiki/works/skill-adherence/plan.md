# Plan of skill-adherence

Stage 5. The units that answer [definition.md](definition.md) with the technology of [technology.md](technology.md). Accepted by the owner (skill-adherence-15).

## Progress

| ID | Status | Evidence | Done on | Owner's words |
|----|--------|----------|---------|---------------|
| skill-adherence-U1 | Done | The description ends at "Returns findings with failing cases." (235 to 208 characters). The Output adds "Then what the change is meant to do, in the one sentence of step 3." after the first line, and "and list no case that passed" after "No findings." (489 to 511 words). On 2026-11-17: `bash scripts/verify.sh` exited 0, `playbook-agents` loads 615 words at session start, limit 620; `claude plugin validate plugins/playbook-agents` passed. Not measured until U5 | 2026-11-17 | Acepto |
| skill-adherence-U2 | Built | The gotcha's example is now "Which breads does the bakery bake each day, and can customers order ahead?", in place of the dental clinic of `prepare-project-new-project-stage-one`; the body stays at 688 words. On 2026-11-17: `grep -rliE "bakery|bread|bake"` over every `prompt.md` and grader under `plugins/*/evals/` found nothing; `bash scripts/verify.sh` exited 0; `claude plugin validate plugins/playbook-wiki` passed. Not measured until U5 | | |
| skill-adherence-U3 | Not started | | | |
| skill-adherence-U4 | Not started | | | |
| skill-adherence-U5 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| skill-adherence-U1 | The report of `review-change` | In `plugins/playbook-agents/skills/review-change/SKILL.md`, the Output says where the sentence of step 3 goes and asks for no list of the cases checked; the description drops "show its report unchanged" (skill-adherence-4) | `bash scripts/verify.sh` exits 0; `claude plugin validate plugins/playbook-agents` passes | Judgement: it changes the text of a skill |
| skill-adherence-U2 | The gotcha of `prepare-project` | In `plugins/playbook-wiki/skills/prepare-project/SKILL.md`, the gotcha's example comes from a domain no case uses (skill-adherence-5) | `bash scripts/verify.sh` exits 0; no word of the example's domain appears in a `prompt.md` under `plugins/*/evals/` | Judgement: it changes the text of a skill |
| skill-adherence-U3 | The graders | `no-findings` widened to the wordings of a clean review in English and Spanish (N6, skill-adherence-9); `no-padding` does not count "Not checked" (N7, skill-adherence-11); `one-question` judges only the closing question (N8, skill-adherence-10) | The widened `regex` matches the last message of the three runs of `review-change-clean-commit` in U6 of skill-triggering, and matches none of the three runs of `review-change-off-by-one` in U6, which report a defect; read from the kept traces, with nothing paid | Evidence; the two `llm` graders are measured in U5 |
| skill-adherence-U4 | The case of `keep-minimal` | `plugins/playbook-agents/evals/keep-minimal-triggers/` gets a `case.yaml` and a `fixture.sh` that commit the over-built change, and its prompt names the commit (N9, skill-adherence-11) | `fixture.sh` run in an empty temporary folder exits 0 and leaves the commit with the five parts the prompt names; `bash scripts/verify.sh` exits 0 | Evidence |
| skill-adherence-U5 | Measurement | One run, when the owner asks, of `review-change-clean-commit` and `prepare-project-new-project-stage-one` with `--ablation with-without`, and of `keep-minimal-triggers` with `--ablation none`: `--runs 3`, `--json`, `--keep-temp`, `--scaffold`, under `--max-cost-usd 3` per skill (N1 to N5) | With the plugin, `no-findings`, `no-padding`, and `not-checked` pass in 3 of 3 runs of `review-change-clean-commit`, `one-question` in 3 of 3 of `prepare-project-new-project-stage-one`, and `keep-minimal-triggers` loads the skill in 3 of 3; results recorded in a page of this work. A case that does not is shown to the owner, with its traces read, before any further change | Evidence |

Order: U1 to U4 change different files and cost nothing; U3 reads the kept traces, so it goes before a reboot clears `/tmp`. U5 measures U1 to U4 together and comes last.

## How a unit is delivered

Accepted by the owner (skill-adherence-15), read from how this repository delivered skill-triggering (skill-triggering-9): the five units are built on this work's branch, `feat/skill-adherence`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). No unit changes stored data, security, or a script, so none needs the `review` agent (R20). A paid run happens only when the owner asks (skill-adherence-7).

## Left out

- A change to the form of a description: skill-adherence-2 leaves the cases of triggering as the only ones that count whether a skill loads, and skill-adherence-6 changes the case, not the description.
- The other cases of `review-change`, `keep-minimal`, and `prepare-project`, and the cases of the other skills, which no decision of this work names.
- A rule in the style guide on where the example of a gotcha comes from: [traces.md](traces.md) shows an example taken from a case primes that case, but no decision of this work changes the style guide.
