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
| Evaluate | `claude plugin eval` with a few cases per skill, tagged by skill, using only the free graders, under a cost ceiling | By hand, before a change to a skill is accepted | Model calls |

The first cases for each skill are two: one request that must trigger it, and one that must not.

## Not verified

- The full list of options of each grader.
- Whether evaluation needs extra software on every operating system. The documentation only says that Windows without a Linux layer has no sandbox for shell commands.
- What a run of this product's suite costs. It can be measured once the first cases exist.
