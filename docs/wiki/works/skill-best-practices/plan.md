# Plan of skill-best-practices

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| skill-best-practices-U1 | Done 2026-11-17, accepted by the owner's judgement | `plugins/playbook-agents/skills/write-skill/references/style-guide.md` gains a section Contents, the rules of a name (G4), references one level deep and Contents over 100 lines (G5), a section Gotchas in the body and its template (G3), writing from the project's material (G8), one default, strictness by fragility, and examples (G6), a section Scripts (G7), and cases of behaviour: three per skill, tagged `<skill-name>-behaviour`, free graders first and `llm` graders for what needs reading, run with a baseline arm on the skill's model (G1, G2). The format of an `llm` grader was read from a case that `claude plugin eval init --bare` wrote in a scratch plugin on 2026-11-17. `write-skill` gains the steps that collect the project's material and write the cases of behaviour before `SKILL.md`; its body has 530 words. Run on 2026-11-17: `bash scripts/verify.sh` passed | 2026-11-17 | Asked "¿Aceptás la U1?"; answered "acepto" |
| skill-best-practices-U2 | Not started | | | |
| skill-best-practices-U3 | Not started | | | |
| skill-best-practices-U4 | Not started | | | |
| skill-best-practices-U5 | Not started | | | |
| skill-best-practices-U6 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| skill-best-practices-U1 | The style guide and `write-skill` | In `plugins/playbook-agents/skills/write-skill/references/style-guide.md`: the format of a case of behaviour and its graders (N1, N2), an optional section Gotchas, the rules of a name, references one level deep with `## Contents` over 100 lines, defaults and examples, the rules of a script, and real material (G3 to G8). In `write-skill`: a new skill starts from its cases of behaviour and the project's own material; an audit checks the new rules | The two files hold each gap of skill-best-practices-1; `bash scripts/verify.sh` exits 0 | Judgement: it is the text of a definition |
| skill-best-practices-U2 | The checks of a name and of references | In `scripts/verify.sh`, the checks of N3 and N4; in `scripts/verify_test.sh`, a failing and a passing case for each. The `review` agent reads the change (R20) | `sh scripts/verify_test.sh` prints "all cases passed" with the new cases; `bash scripts/verify.sh` exits 0 on the repository; `shellcheck` prints nothing | Evidence |
| skill-best-practices-U3 | The cases of `write-skill`, and the cost | Three cases of behaviour for `write-skill` in `plugins/playbook-agents/evals/`; one run with `--model sonnet --max-cost-usd 2`, when the owner asks (skill-best-practices-3) | Each case passes in the arm with the plugin; the scores of both arms and the cost are recorded; the owner sets the ceiling for U6 | Evidence |
| skill-best-practices-U4 | The audit of the skills of `playbook-wiki` and of `init` | `prepare-project`, `write-docs`, `doctor`, and `init` audited with `write-skill` and fixed, `init.sh` and `wiki-format.sh` against the rules of a script (skill-best-practices-5) | Each finding fixed or answered; `bash scripts/verify.sh` exits 0 | Judgement: it changes the text of skills |
| skill-best-practices-U5 | The audit of the skills of `playbook-agents` | `keep-minimal`, `review-change`, and `avoid-generic-design` audited with `write-skill` and fixed | Each finding fixed or answered; `bash scripts/verify.sh` exits 0 | Judgement: it changes the text of skills |
| skill-best-practices-U6 | The cases of the other six skills | Three cases of behaviour for each of `prepare-project`, `write-docs`, `doctor`, `keep-minimal`, `review-change`, and `avoid-generic-design`; one run per skill under the ceiling of U3, `review-change` on `opus` by its agent, the others on `sonnet`, when the owner asks | Each case passes in the arm with the plugin; the scores of both arms and the cost are recorded | Evidence |

Order: U1 first, since every other unit follows the new guide; U2 needs the `## Contents` that U1 adds to the style guide. U3 measures the cost before U6 spends it. U4 and U5 come before U6, so the cases test the fixed text.

## How a unit is delivered

Accepted by the owner (skill-best-practices-9), read from how this repository delivers (TD5, D196): the six units are built on this work's branch, `feat/skill-best-practices`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). U2 changes `verify.sh`, so the `review` agent reads it before it is Done (R20). A paid run of `claude plugin eval` happens only when the owner asks (skill-best-practices-3).

## Left out

- Testing each skill on Haiku, Sonnet, and Opus (G2 in full), and the description in third person (G9): skill-best-practices-1.
- Cases of behaviour for `init` (skill-best-practices-5).
- The twenty queries per skill that agentskills.io proposes to tune a description.
