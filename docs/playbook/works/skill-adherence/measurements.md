# Measurements of skill-adherence

What the run of [skill-adherence-U5](plan.md) showed.

## skill-adherence-U5

Run on 2026-11-17 with Claude Code 2.1.326, `--model sonnet --runs 3 --scaffold --keep-temp --no-publish -j 4 --allow-tools Bash Write Edit`, from `plugins/`, each skill under `--max-cost-usd 3` (skill-adherence-7). The owner asked for the run ("si"). Cost: USD 1.39: `review-change` 0.59, `keep-minimal` 0.18, `prepare-project` 0.62.

| Case | Arm | Runs that passed each grader | Before, in skill-triggering |
|------|-----|------------------------------|-----------------------------|
| `review-change-clean-commit` | with the plugin | `skill-loaded` 3 of 3, `no-findings` 3, `no-padding` 3, `not-checked` 2 | U6: `no-findings` 1, `no-padding` 0, `not-checked` 2 |
| `review-change-clean-commit` | without | `no-findings` 3, `no-padding` 0, `not-checked` 0 | U6: 0, 0, 0 |
| `keep-minimal-triggers` | with the plugin | `skill-loaded` 1 of 3 | U5: 1 of 3 |
| `prepare-project-new-project-stage-one` | with the plugin | `skill-loaded` 3 of 3, `one-question` 2 of 3 | U5: `one-question` 1 of 3 |
| `prepare-project-new-project-stage-one` | without | `one-question` 0 of 3 | U5: 0 of 3 |

The ending condition of U5 does not hold in three runs.

What the traces of those three runs show:

- `review-change-clean-commit`, the run that failed `not-checked`: the session's last message says "Two things weren't checked:" and lists them. The report has its "Not checked"; the `regex` accepts only "Not checked" and a few Spanish forms at the start of a line, as `no-findings` did before skill-adherence-9.
- `keep-minimal-triggers`, the two runs that did not load the skill: the agent ran `git show HEAD` itself and answered well, naming the five parts and giving the one line the task needs. Making the request need the repository (skill-adherence-6) did not make the agent load the skill, though its description names "unnecessary complexity".
- `prepare-project-new-project-stage-one`, the run that failed `one-question`: the answer ends "Does the clinic have several dentists, and are all appointments the same length?", one question that asks two things. The gotcha's new example did not reappear; the brief of the case invites a question of that shape.
