# Skill evaluation

Evaluation for Q29, made on 2026-11-13 against the current Claude Code documentation and the version installed on the owner's machine (2.1.323). D32 asks for evaluation cases and a verify script per skill. The owner accepted the two layers below (Decided: TD4).

## What Claude Code provides

| Command | What it checks | Cost | Evidence |
|---------|----------------|------|----------|
| `claude plugin validate <path>` | Structure only: the plugin and marketplace manifests, and the front matter of skills, agents, and commands | Free | Help text on this machine |
| `claude plugin eval <target>` | Behaviour: runs each case in a fresh session with only the plugin loaded, and scores it with graders | Every run is a model call billed to the account | [Plugin evals](https://code.claude.com/docs/en/plugin-evals.md); the command exists on this machine |
| `/skill-doctor` | Use: what each skill costs in context, how often it is called, and which were never called | Free | [Skills](https://code.claude.com/docs/en/skills.md) |

## How an evaluation suite is written

- The suite lives in `evals/` at the root of the plugin. Each case is a folder with `prompt.md` and one file per grader in `graders/`.
- Graders that cost nothing: `regex`, `tool_used`, `tool_order`, `file_exists`. Graders that call a judge model: `llm`, `baseline`.
- "The skill triggers for this request" is a `tool_used` grader on the `Skill` tool. "The skill does not trigger" is the same grader with a minimum and maximum of zero.
- A run is limited to chosen cases with `--case` or `--tag`. There is no selector per skill, so each case is tagged with its skill.
- By default each case runs three times, and the suite also runs once without the plugin as a baseline, which doubles the cost. `--max-cost-usd` sets a ceiling.
- The result is a table, an HTML report, and JSON. The exit code is 0 only when every case passes, so a shell script can use it (TD2).

## Limits

- No free trial run: every behaviour check calls the model.
- The documentation does not say whether the command is generally available. It describes two gates: an old build, and a switch on Anthropic's side that nothing local turns back on.
- `/skill-doctor` reports use and cost. It does not judge whether a description is good.

## Chosen use (Decided: TD4)

Use what Claude Code already provides, in two layers, and write no runner:

| Layer | What runs | When | Cost |
|-------|-----------|------|------|
| Verify | One shell script: `claude plugin validate`, plus the size limits of D32 | On every change | Free |
| Evaluate | `claude plugin eval` with a few cases per skill, tagged by skill, using the free graders, and `llm` graders only in the cases of behaviour (skill-best-practices-1), under a cost ceiling | By hand, before a change to a skill is accepted | Model calls |

The first cases for each skill were two: one request that must trigger it, and one that must not.

## Cases of behaviour (Decided: skill-best-practices-1, -6)

Beside its two cases of triggering, a skill gets three cases of behaviour, tagged `<skill>-behaviour`, each a real task of its job. A case runs in two arms, with the plugin and without it (`--ablation with-without`), and passes when its graders pass in the arm with the plugin; the report also gives the score without it. A case that passes as well without the plugin proves nothing and is replaced. Graders that cost nothing come first; an `llm` grader, judged by `haiku`, only where a reading is needed. The format of a case is in [the style guide of `write-skill`](../../../plugins/playbook-agents/skills/write-skill/references/style-guide.md); `init` has none, because a case would change the plugin settings it runs in (skill-best-practices-5).

Run on `sonnet` for a skill that runs in the session, and on its agent's model for a skill that forks: `review-change` runs on `opus` through `models.conf` (skill-best-practices-6). The other two models are not tried: one model per skill keeps the cost down (skill-best-practices-1).

## Whether a skill loads (Decided: skill-triggering-6, -11, skill-adherence-2)

A case of triggering passes when its skill loads in 3 of 3 runs, and a case of not triggering when it loads in 0 of 3. A case of behaviour passes on its behaviour, whether the skill loads or not (skill-adherence-2, which replaces skill-triggering-2 for the cases of behaviour). A measurement runs every case three times with `--runs 3`, writes each run's graders and the path of its trace with `--json <file>`, and keeps the run's folders with `--keep-temp`; a case that fails is read in its trace before the skill changes. The cases of triggering run with `--ablation none`, since a skill cannot load without its plugin; the cases of behaviour with `--ablation with-without` (skill-triggering-6). A case of behaviour that asks for something the contract already refuses, such as code before stage 6, does not ask its skill to load (skill-triggering-11).

The traces a run keeps in `/tmp/claude-eval-*` are found through `cases[].arms.with[].tracePath` and `.without[]` of its `--json` report. They are read before a new paid run, and a reboot deletes them (skill-adherence-3).

## What a grader reads (Decided: skill-adherence-4, -9, -10, -11, -16)

- A forked skill returns its result to the session, which writes the last message, and may reword it. Claude Code's documentation names no way to show that result unchanged ([Skills](https://code.claude.com/docs/en/skills.md), "Run skills in a subagent"), so a grader reads the meaning, not the skill's exact words (skill-adherence-4).
- A `regex` on the last message accepts the wordings of the same meaning in English and Spanish: "No findings", "found no defects", "no encontré defectos" (skill-adherence-9); "Not checked", "Two things weren't checked", "Qué no se verificó" (skill-adherence-16). Each widened `regex` is checked on the kept last messages before it is used.
- An `llm` grader judges only what the skill's Output asks: for `review-change`, what is under "Not checked" is not a finding (skill-adherence-11); for `prepare-project`, only the question that ends the reply, where a blocked step reported with its command is not a question (skill-adherence-10).
- A case of triggering gets a scaffold, and `Bash`, when its request names a change in the repository, as `keep-minimal-triggers` does (skill-adherence-11).

## Cost and ceiling (Decided: skill-best-practices-3, -10)

The cost was measured first, on `write-skill` under a ceiling of USD 2 with `--max-cost-usd`: USD 0.84 for its three cases, about USD 0.09 a run with the skill and 0.05 without. The ceiling of the other six was set from that: USD 1 per skill and per run, one run per arm (skill-best-practices-10). A skill that reaches it is stopped and its result shown to the owner. Measured, a run of one skill's three cases costs about USD 0.4 to 0.5. A paid run happens only when the owner asks.

## Running a case that needs more

- A plugin with a dependency (`playbook-agents` needs `playbook-wiki`) loads only with it. Without it Claude Code drops the plugin, and both arms run without the skill. Each case lists both on a `plugins:` line of its `prompt.md`, and the run starts from `plugins/` with `--eval-dir <plugin>/evals` and `--ablation with-without` (skill-best-practices-3).
- `--scaffold` builds a case's workspace from its `scaffold_script`. Without it the case runs in an empty folder: the first paid run of the cases of behaviour was void for it (skill-best-practices-12).
- `--keep-temp` keeps the run's folders, to read what the agent did when a case fails (skill-best-practices-13).
- `--allow-tools <tool>` for each tool a case lists beyond Read, Glob, Grep, and Skill.
- The check that every case loads is free: run the command with `--case no-such-case`; it reports each file it cannot read and runs nothing.
- The arm with the plugin also gets the owner's plugin settings, such as the language of `playbook-agents`. A grader on the answer accepts each language it may come in, and a scaffold sets git's `user.name` to the person its documents name as the owner (skill-best-practices-13).
- A grader `skill-loaded` that is not scored shows whether the skill loaded (skill-best-practices-13).
- In the sandbox of a run, `Bash` reads the case's folder but cannot write it; the `Write` tool can. A script that writes the project's files, such as `wiki-format.sh mark`, fails there (skill-triggering-U2).

## Result of the first runs (Decided: skill-best-practices-14)

The cases of the seven skills ran, those of the six others three times, and the work closed with the evidence of the third run, though not every case passes with the plugin. What fails is mostly a skill that does not load, or a fault shown in a run, and each is an open question of the work skill-best-practices, for a later work: skill-best-practices-Q1 (descriptions that did not load for `review-change`, `keep-minimal`, and `prepare-project`), skill-best-practices-Q2 (`review-change` ends with a question), skill-best-practices-Q3 (`prepare-project` asks two questions at once), skill-best-practices-Q4 (`avoid-generic-design` builds three equal columns), and skill-best-practices-Q5 (`wiki-format.sh mark` fails where the temporary folder cannot be written). See [the questions](../works/skill-best-practices/questions.md).

## Result of the work skill-triggering (Decided: skill-triggering-13, skill-triggering-16)

The work skill-triggering took those five questions, measured four skills three times per case, and changed what the traces showed: new words in the descriptions of `review-change` and `keep-minimal`, a gotcha in `prepare-project`, and `wiki-format.sh mark` keeps its copy of the marker beside it. It cost USD 15.28 in three measurements. Below skill-triggering-2 after its last run, each an open question for a later work: a small task the agent does itself without loading the skill (skill-triggering-Q5), `prepare-project` ending with more than one question (skill-triggering-Q6), and the report of `review-change` changed before it reaches the owner (skill-triggering-Q7). See [the measurements](../works/skill-triggering/measurements.md) and [the questions](../works/skill-triggering/questions.md).

## Result of the work skill-adherence (Decided: skill-adherence-16)

The work skill-adherence took skill-triggering-Q5 to -Q7, read their causes in the kept traces, changed the Output of `review-change`, the example of the gotcha of `prepare-project`, and the graders, and measured once, for USD 1.39. With the plugin, `review-change-clean-commit` passes `no-findings` and `no-padding` in 3 of 3, and `prepare-project-new-project-stage-one` asks one question in 2 of 3. Left open for a later work: `keep-minimal-triggers` loads its skill in 1 of 3, since the agent reviews the commit itself (skill-adherence-Q7), and whether 2 of 3 is enough for `prepare-project` (skill-adherence-Q8). See [the measurements](../works/skill-adherence/measurements.md) and [the questions](../works/skill-adherence/questions.md).

## Not verified

- Whether evaluation needs extra software on every operating system. The documentation only says that Windows without a Linux layer has no sandbox for shell commands.
