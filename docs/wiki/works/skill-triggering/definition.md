# Definition of the work skill-triggering

What this work must make true: the skills of the playbook load when a request calls for them, and do what their text says once loaded. It takes the five questions the work skill-best-practices left open, [skill-best-practices-Q1 to -Q5](../skill-best-practices/questions.md) (skill-triggering-1).

## The problem

The work skill-best-practices gave each skill cases of behaviour and ran them with `claude plugin eval`, one run per arm, on 2026-11-17. The scores of that third run, and whether the skill loaded, are in its unit [skill-best-practices-U6](../skill-best-practices/plan.md). Five faults remained:

| Question taken | Fault seen in the run | Case |
|----------------|-----------------------|------|
| skill-best-practices-Q1 | The skill did not load, and the agent did the task without it | `review-change-clean-commit`, `review-change-empty-input`, `keep-minimal-add-feature`, `prepare-project-no-code-before-stage-six` |
| skill-best-practices-Q2 | `review-change` ends its report with a question, which its Output forbids | `review-change-off-by-one` |
| skill-best-practices-Q3 | `prepare-project` asks two questions in its first answer; the skill or the roles check of the contract may cause it | `prepare-project-new-project-stage-one` |
| skill-best-practices-Q4 | `avoid-generic-design` built a page with three equal columns, and scored lower than without the skill: 0.78 with it, 0.89 without | `avoid-generic-design-build-page` |
| skill-best-practices-Q5 | `wiki-format.sh mark` copies the marker with `mktemp` (`plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh`, line 84); where the temporary folder cannot be written it exits 4 | `doctor-one-format-behind` |

Each run was a single run per arm, so a skill that loads in some runs and not in others looks the same as one that never loads. `claude plugin eval` runs a case three times by default (`--runs <n>`, "default: case.runs ?? 3", from `claude plugin eval --help`, Claude Code on 2026-11-17).

The cases live in `plugins/playbook-wiki/evals/` and `plugins/playbook-agents/evals/`; how they run is in [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md).

## Who has it

The person who installs the playbook. A request such as "Review the last commit before I merge it" should load `review-change`; when it does not, the review comes from the session's own judgement, without the skill's rules.

## What the work must do

- Measure how often each skill of the table loads, with three runs per case, before changing its text. A skill loads reliably when each case that calls for it loads it in 3 of 3 runs, and each case of not triggering in 0 of 3 (Decided: skill-triggering-2).
- Change the words of the description of `review-change`, `keep-minimal`, and `prepare-project` until their cases load, and measure again (Decided: skill-triggering-4).
- Add to `review-change`, `prepare-project`, and `avoid-generic-design` what fixes the faults of skill-best-practices-Q2 to -Q4, each measured in the same runs (Decided: skill-triggering-1).
- Make `wiki-format.sh mark` work where the temporary folder cannot be written, with its test (Decided: skill-triggering-1).

## What the work must not do

- Raise the limit of a description, 250 characters, or of a body, 700 words, which skill-best-practices-1 kept (Decided: skill-triggering-4).
- Change the form of a description, unless its words alone do not reach skill-triggering-2 (Decided: skill-triggering-4).
- Run a paid evaluation without the owner asking (Decided: skill-triggering-3).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above |
| Who uses it | Covered: the person who installs the playbook, and the agent that loads the skills |
| Main flows | Covered: a request that should load a skill; a run of the cases that measures it |
| What it must do | Covered: skill-triggering-2 |
| What it must not do | Covered: skill-triggering-3, -4 |
| Qualities | Covered: the limits of [../../01-product/style-guide.md](../../01-product/style-guide.md) stay |
| Limits | Covered: measured first, under USD 3 per skill, and the later ceiling set from that cost (skill-triggering-3) |
| Outside systems | Covered: `claude plugin eval` and Anthropic's models |
| Volume | Covered: four skills to change, `review-change`, `keep-minimal`, `prepare-project`, `avoid-generic-design`, and one script |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: the terms of the style guide and of [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) |

## Not verified

- Whether a skill that did not load in one run loads in others: no case ran more than once per arm.
