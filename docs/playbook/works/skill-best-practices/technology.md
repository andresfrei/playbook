# Technology of skill-best-practices

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: the work uses the two layers of TD4, `scripts/verify.sh` and `claude plugin eval`.

Checked on 2026-11-17 by running `claude plugin eval --help` (Claude Code 2.1.326) and by reading `scripts/verify.sh`, `scripts/verify_test.sh`, and the skills:

- `claude plugin eval` runs each case with the plugin and in a baseline arm without it (`--ablation with-without`, the default when a plugin resolves), takes `--model` for every case, and grades with free graders (`regex`, `tool_used`, `tool_order`, `file_exists`) or with `llm` graders judged by `--judge-model`, `haiku` by default.
- `verify.sh` checks the front matter's keys, the body (L2), and the description (L3) of each skill, and that no skill reads a file inside another; `verify_test.sh` holds a case for each check.
- Of the eight skills, `review-change` runs in a separate context on the agent `review`, whose model `models.conf` sets to `opus`; `doctor` and `init` only the owner starts. `prepare-project` has 700 words, the limit, and `write-docs` 690. The longest reference file, the style guide of `write-skill`, has 162 lines; the others have at most 58.

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Cases of behaviour, run with and without the skill (G1) | Three cases for each of the seven skills of skill-best-practices-2, none for `init` (skill-best-practices-5), beside its two cases of triggering, under `evals/` of its plugin, run with `claude plugin eval` and its default baseline arm. A grader is free where the result can be seen in a file, a tool call, or the text; an `llm` grader, judged by `haiku`, where only a reading can say | Decided (skill-best-practices-6) |
| N2 | The model each case runs on (G2) | `--model sonnet` for a skill that runs in the session; `review-change` runs on its agent's model, `opus`, by `models.conf` | Decided (skill-best-practices-6) |
| N3 | The rules of a name (G4) | `verify.sh` fails on a skill's `name` over 64 characters, with a leading, trailing, or double hyphen, or with the word `claude` or `anthropic`; a case in `verify_test.sh` for each | Decided (skill-best-practices-6) |
| N4 | References one level deep, and a table of contents (G5) | `verify.sh` fails on a reference file that names another file of `references/`, and on one over 100 lines with no `## Contents` heading; a case in `verify_test.sh` for each | Decided (skill-best-practices-6) |
| N5 | Gotchas, defaults, examples, scripts, and real material (G3, G6, G7, G8) | Text in the style guide and in `write-skill`; checked by the audit of `write-skill` and the owner's review, since no script can judge it | Decided (skill-best-practices-6) |
| N6 | Room for a gotchas section in skills at the limit (G3, skill-best-practices-1) | A skill over 700 words moves its least-used detail to a reference file, as the style guide already says | Decided (skill-best-practices-6) |

## Architecture

Nothing changes in shape. The style guide of `write-skill` gains the rules adopted; `write-skill` gains a step that writes the cases of behaviour before the skill's text; `verify.sh` gains the checks of N3 and N4; each plugin's `evals/` gains three cases per skill.

Risks:

- The cost of a run is unknown. Reduced by skill-best-practices-3: measured on `write-skill` under USD 2 first.
- An `llm` grader may judge the same output differently on two runs. Reduced by preferring a free grader, and by three runs per case, the default.
- A gotcha that does not fit pushes `prepare-project` or `write-docs` over 700 words. Reduced by N6.

Trade-offs: N2 gives up testing each skill on all three models (G2 in full) to keep the cost to one model per skill (skill-best-practices-1).

Not applicable: data and outside systems beyond Anthropic's models, which TD4 already uses.
