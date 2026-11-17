# Technology of skill-triggering

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: the work uses `claude plugin eval` and the cases that the work skill-best-practices wrote, as [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) describes, and the tests of `scripts/verify_test.sh`.

Checked on 2026-11-17, by running `claude --version` (2.1.326) and `claude plugin eval --help`, and by reading the cases under `plugins/*/evals/`, `plugins/playbook-agents/agents/review.md`, `plugins/playbook-agents/skills/review-change/SKILL.md`, and `plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh`:

- `--runs <n>` sets the runs of each case: "default: case.runs ?? 3". The runs of skill-best-practices-U6 were one per arm.
- `--ablation none | with-without` chooses whether a baseline arm without the plugin runs. `--tag <tag...>` filters the cases by tag. A case of triggering is tagged `<skill>`, a case of behaviour `<skill>-behaviour`.
- `--json [path]` writes "the full run result (prompts, graders, per-run scores)". `--keep-temp` keeps the scaffold folders. `--max-cost-usd <usd>` stops the run before it passes a ceiling.
- Each case that must load a skill has a grader `skill-loaded`, of type `tool_used`, that matches a call of the `Skill` tool with the skill's name.
- `review-change` forks into the agent `playbook-agents:review` (`context: fork`), which runs on `opus` and preloads the skill (`skills: review-change`). The cases of `review-change` allow `Read`, `Glob`, `Grep`, `Skill`, and, for behaviour, `Bash`; not `Agent`.
- `wiki-format.sh mark` keeps the old marker in a file made by `mktemp` (line 84), and exits 4 when that fails.

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Three runs per case (skill-triggering-2) | `--runs 3` on every measurement | Decided (skill-triggering-6) |
| N2 | A record of whether the skill loaded in each run, and what the agent did when it did not | `--json <file>` beside the report, and `--keep-temp`; the file is read for the grader `skill-loaded` of each run | Decided (skill-triggering-6) |
| N3 | Spend only where a measurement says something (skill-triggering-3) | The cases of triggering run with `--tag <skill> --ablation none`, since the skill cannot load without the plugin; the cases of behaviour with `--tag <skill>-behaviour --ablation with-without`, as before | Decided (skill-triggering-6) |
| N4 | The model of each case | As skill-best-practices-6 decided: `--model sonnet`, and `review-change` on `opus` through its agent | Decided (skill-best-practices-6) |
| N5 | A ceiling per measurement | `--max-cost-usd 3` per skill on the first measurement (skill-triggering-3); the later ceiling set from its cost | Decided (skill-triggering-3) |
| N6 | `wiki-format.sh mark` where the temporary folder cannot be written (skill-best-practices-Q5) | Keep the copy of the old marker beside it, in the wiki's folder, which `mark` must write anyway; a case in `scripts/verify_test.sh` with an unwritable `TMPDIR` | Decided (skill-triggering-6) |

## Architecture

Nothing changes in shape. What changes is text and one script:

- The descriptions of `review-change`, `keep-minimal`, and `prepare-project`, in their `SKILL.md`, within 250 characters (skill-triggering-4).
- A gotcha in `review-change`, `prepare-project`, and `avoid-generic-design`, within 700 words.
- `wiki-format.sh mark`, and its test.

Each change to a skill is measured with the cases that already exist; a case changes only when a trace shows it measures the wrong thing.

Risks:

- A run of `review-change` may reach the review through another route than the `Skill` tool, and the grader `skill-loaded` would count it as not loaded. Reduced by N2: the trace of each run is read before its description changes.
- Three runs cost three times one. Reduced by N3 and N5.
- An interrupted `mark` may leave the copy of the marker in the wiki's folder. Reduced by deleting it on every exit, as the copy in the temporary folder is now.

Trade-offs: N3 gives up the score without the plugin in the cases of triggering, which is always "not loaded".

Not applicable: data and outside systems beyond Anthropic's models, which [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) already uses.

## Not verified

- That `--json` holds each run's grader `skill-loaded`, and not only the score of the case: read on the first run.
- How many of the runs of skill-best-practices-U6 that did not load the skill reached it another way: their traces were not kept.
