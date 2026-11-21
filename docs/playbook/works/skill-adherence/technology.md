# Technology of skill-adherence

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: the work uses `claude plugin eval` and the cases under `plugins/*/evals/`, as [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) describes.

Checked on 2026-11-17 by running `claude --version` (2.1.326) and `claude plugin eval --help`, and by reading the cases `prepare-project-new-project-stage-one`, `review-change-clean-commit`, and `keep-minimal-triggers`:

- A case is a folder with `prompt.md`, `graders/*.md`, and, when it needs files, `case.yaml` with `context.scaffold_script` pointing to a `fixture.sh`, run only with `--scaffold`. `keep-minimal-triggers` has no `case.yaml` and no fixture.
- The graders in use are of four types: `regex` and `llm` on the last message, `tool_used`, and `file_exists`. `--judge-model` sets the judge, `haiku` by default.
- `review-change-clean-commit` grades "No findings" with a `regex` that accepts no other wording in English, and "no padding" with an `llm` grader that fails any finding.

From the documentation of plugin evaluations, https://code.claude.com/docs/en/plugin-evals.md, read on 2026-11-17 through an agent that quotes it:

- No field of `case.yaml` and no flag lets `Bash` write more: "A case's `allowed_tools` and a skill's own `allowed-tools` frontmatter can't widen any of them". `context` holds `scaffold_script`, `history_file`, and `add_dirs`, which is read-only.
- Six types of grader, "no custom-code graders": `regex`, `tool_used`, `tool_order`, `file_exists`, `llm`, `baseline`. A `regex` reads with `target`, an `llm` with `focus`: `last_message` by default, `trace`, `files`, the contents of one file, or `mock_calls`. A forked skill's result is reachable only through `trace`.

From https://code.claude.com/docs/en/skills.md, section "Run skills in a subagent": a forked skill "summarizes its results and returns them to your main conversation". The page names no option to show that result unchanged; `background: false` only makes the session wait for it. This supports skill-adherence-4.

## Needs already met

The technology of skill-triggering stays as it is; it is not decided again:

| # | Need | Choice | Source |
|---|------|--------|--------|
| N1 | Three runs per case | `--runs 3` | skill-triggering-6 |
| N2 | A record of each run | `--json <file>` and `--keep-temp` | skill-triggering-6 |
| N3 | Spend only where a measurement says something | Cases of triggering with `--ablation none`, cases of behaviour with `--ablation with-without` | skill-triggering-6 |
| N4 | The model of each case | `--model sonnet`; `review-change` on `opus` through its agent | skill-best-practices-6 |
| N5 | A ceiling per measurement | `--max-cost-usd 3` per skill, each run when the owner asks | skill-adherence-7 |

## New needs

| # | Need | Choice | Status |
|---|------|-----------------|--------|
| N6 | A grader of "no findings" that reads the meaning (skill-adherence-4) | The `regex` widened to the wordings of a clean review in English and Spanish, such as "no defects" and "no encontré defectos" | Decided (skill-adherence-9) |
| N7 | A grader of padding that does not count "Not checked" (skill-adherence-4) | Rewrite the criteria of the `llm` grader `no-padding`: a finding is a defect reported as wrong; what is under "Not checked" is not one | Decided (skill-adherence-11) |
| N8 | A case of `prepare-project` that does not depend on `Bash` writing in the sandbox (skill-adherence-5) | The `llm` grader `one-question` judges only the question that ends the reply: a blocked step reported with its command is not a question; one question that asks two things fails | Decided (skill-adherence-10) |
| N9 | A case of triggering for `keep-minimal` whose request names a change in the repository (skill-adherence-6) | A `case.yaml` and a `fixture.sh` that commit the over-built change, as the cases of `review-change` do; the prompt names the commit | Decided (skill-adherence-11) |

## Architecture

Nothing changes in shape: no module, hook, data, or outside system is added. What changes is text in three skills and their cases:

| Path | Change | Decision |
|------|--------|----------|
| `plugins/playbook-agents/skills/review-change/SKILL.md` | The Output places the sentence of step 3 and asks for no list of the cases checked; the description drops "show its report unchanged" | skill-adherence-4 |
| `plugins/playbook-agents/evals/review-change-clean-commit/graders/` | `no-findings` widened (N6); `no-padding` does not count "Not checked" (N7) | skill-adherence-4, -9 |
| `plugins/playbook-wiki/skills/prepare-project/SKILL.md` | The gotcha's example comes from another domain than a dental clinic | skill-adherence-5 |
| `plugins/playbook-wiki/evals/prepare-project-new-project-stage-one/graders/one-question.md` | Judges only the closing question (N8) | skill-adherence-10 |
| `plugins/playbook-agents/evals/keep-minimal-triggers/` | A fixture commits the over-built change, and the prompt names it (N9) | skill-adherence-6 |

Risks:

- A widened `regex` passes a report that says "no defects" and then lists one. Reduced by `no-padding`, which fails any finding.
- An `llm` judge is not stable: it passed and failed the same question in U5 ([traces.md](traces.md)). Reduced by three runs per case, and by reading the trace of each failure before changing a skill.
- A new example in the gotcha may prime another case the same way. Reduced by an example from a domain no case uses.

Trade-offs:

- N8 gives up measuring whether the agent asks for more when a step fails, which the sandbox of a run causes and a real session does not.
- Recording the relay as Claude Code's (skill-adherence-4) gives up a report that reaches the owner word for word, since the documentation names no way to do it.

Discarded: letting `Bash` write in the sandbox, since the documentation offers no field or flag for it; running `review-change` without its fork, which would give up a reader that has not seen the conversation.

Not applicable: data and outside systems beyond Anthropic's models and `claude plugin eval`, which [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) already describes.
