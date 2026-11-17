# Measurements of skill-triggering

What each run of `claude plugin eval` showed for the cases of [skill-triggering-U2 and -U5](plan.md). Each case ran three times per arm (skill-triggering-2, -6).

## First measurement, skill-triggering-U2

Run on 2026-11-17 with Claude Code 2.1.326, `--model sonnet --runs 3 --scaffold --keep-temp --no-publish -j 4 --allow-tools Bash Write Edit`, from `plugins/`. The cases of triggering ran with `--ablation none --max-cost-usd 1`, the cases of behaviour with `--ablation with-without --max-cost-usd 2`. The owner asked for the run ("si").

Cost: USD 8.03. Per skill: `review-change` 1.80, `keep-minimal` 1.53, `prepare-project` 2.45, `avoid-generic-design` 2.25. No skill reached its ceiling of USD 3.

"Loaded" counts the runs whose grader `skill-loaded` passed. A case of not triggering passes when the skill is not loaded.

| Case | Loaded with the plugin | Scores with the plugin | Scores without |
|------|------------------------|------------------------|----------------|
| `review-change-triggers` | 3 of 3 | 1, 1, 1 | not run |
| `review-change-does-not-trigger` | 0 of 3, as it should | 1, 1, 1 | not run |
| `review-change-clean-commit` | 3 of 3 | 0.33, 0, 0 | 0, 0, 0 |
| `review-change-empty-input` | 0 of 3 | 0.67, 0.67, 0.67 | 0.67, 0.5, 0.67 |
| `review-change-off-by-one` | 0 of 3 | 0.4, 0.6, 0.6 | 0.4, 0.4, 0.6 |
| `keep-minimal-triggers` | 2 of 3 | 1, 1, 0 | not run |
| `keep-minimal-does-not-trigger` | 0 of 3, as it should | 1, 1, 1 | not run |
| `keep-minimal-add-feature` | 0 of 3 | 0.67, 0.67, 0.5 | 0.67, 0.67, 0.67 |
| `keep-minimal-review-excess` | 2 of 3 | 0.25, 0.75, 0.75 | 0.5, 0.5, 0.5 |
| `keep-minimal-rule-required` | 3 of 3 | 1, 1, 1 | 0.75, 0.5, 0.5 |
| `prepare-project-triggers` | 3 of 3 | 1, 1, 1 | not run |
| `prepare-project-work-triggers` | 3 of 3 | 1, 1, 1 | not run |
| `prepare-project-new-phase-triggers` | 3 of 3 | 1, 1, 1 | not run |
| `prepare-project-does-not-trigger` | 0 of 3, as it should | 1, 1, 1 | not run |
| `prepare-project-close-stage-spanish` | 3 of 3 | 1, 1, 1 | 0.5, 0.83, 0.83 |
| `prepare-project-new-project-stage-one` | 3 of 3 | 0.67, 0.67, 0.67 | 0.67, 0.67, 0.67 |
| `prepare-project-no-code-before-stage-six` | 0 of 3 | 1, 1, 1 | 0.33, 0.33, 0.33 |
| `avoid-generic-design-triggers` | 3 of 3 | 1, 1, 1 | not run |
| `avoid-generic-design-does-not-trigger` | 0 of 3, as it should | 1, 1, 1 | not run |
| `avoid-generic-design-build-page` | 3 of 3 | 0.89, 1, 0.89 | 0.67, 0.89, 0.89 |
| `avoid-generic-design-own-design-system` | 3 of 3 | 1, 0.25, 1 | 0.75, 0.75, 1 |
| `avoid-generic-design-review-page` | 3 of 3 | 0.75, 0.75, 0.75 | 0.75, 0.75, 0.75 |

## What the traces show

Read from the trace of each run, kept by `--keep-temp`:

- `review-change` did not load for "Review my uncommitted changes before I commit them" (`off-by-one`) nor for "Mirá lo último que subí, ¿hay algo roto?" (`empty-input`). In the six runs the agent reviewed with `Bash` and wrote its own report; no run reached the agent `review` another way. The closing question of skill-best-practices-Q2 came only in these runs, without the skill.
- In `review-change-clean-commit` the skill loaded in each run, and the review found no defect, but the session's last message rewrites the report of the forked agent: "found no defects" or "no encontré defectos" instead of "No findings.", "open points" that are not defects, and in two runs no "Not checked".
- `keep-minimal` did not load in `add-feature`, a request to add a cache; the agent still refused the cache and fixed the slow loop, with the same score as without the plugin. In `keep-minimal-triggers` and `review-excess` it loaded in two runs of three; in the other, the agent answered the review itself.
- `prepare-project` did not load in `no-code-before-stage-six`, a request to write code now, but the agent refused and named the open stage, reading the wiki as the contract of `playbook-wiki` says: 1.00 with the plugin, 0.33 without.
- In `prepare-project-new-project-stage-one` the skill loaded, and the grader `one-question` failed in both arms. With the skill the last answer asks one question of the work, then a second one inside it ("How many dentists… and do treatments differ in length?"), and also asks the owner to run `wiki-format.sh mark`, because the sandbox of the run let `Bash` read the project's folder but not write it.
- `avoid-generic-design-build-page` built no three equal columns in the three runs with the plugin; one run without it did. skill-best-practices-Q4 did not show again.

## Not verified

- Whether the sandbox of `claude plugin eval` lets `Bash` write the project's folder in the cases of `doctor`, where `mark` must write the marker: their cases did not run in U2.
