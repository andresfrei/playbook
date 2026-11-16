# Style guide

The format of the product's rules file and skills, and the size limits the verify script enforces (D32, TD4). Unit U1 of the [plan](../05-plan/plan.md). The owner accepted it (Decided: D48).

## Limits

Limits are counted in words and characters, not tokens, because the verify script is plain shell (TD2) and can count those exactly.

| # | What | Limit | Today, measured 2026-11-13 |
|---|------|-------|-----------------------------|
| L1 | The rules file | 500 words | R1–R17 are 231 words. Claude Code cuts hook output at 10,000 characters, about 1,500 words |
| L2 | The body of a skill file, without its front matter | 700 words | The installed style guide sets 1,000 tokens, about 750 words. The seven skills the product starts from run from 344 to 664 words |
| L3 | A skill description | 250 characters | The installed style guide sets 250. The 43 installed skills have a median of 255 and a maximum of 767. Claude Code cuts at 1,536 |
| L4 | Everything the product loads at session start: the rules file plus every skill description | 800 words | Today about 15,400 words load: 13,512 of global instructions and about 1,900 of skill descriptions |

L4 leaves room for about seven skills at the L3 limit. Adding a skill beyond that means removing or shortening something.

A file over a limit fails the verify script. Text that does not fit moves to a reference file, which loads only when the skill needs it.

## Limits of a project's wiki

Two limits apply to the wiki that `prepare-project` creates in a project, not to the plugin (D138). They are stated in [`plugin/skills/prepare-project/references/1-wiki.md`](../../../plugin/skills/prepare-project/references/1-wiki.md); why they exist is in [wiki-maintenance.md](wiki-maintenance.md).

| What | Limit | Enforced by |
|------|-------|-------------|
| The section "Where work stands" of the wiki's `README.md` | 250 words | `plugin/skills/prepare-project/scripts/check-wiki.sh`, which also fails on a relative link that does not resolve and on a path the wiki names as code that does not exist (D160) |
| The text of a decision in `decisions.md` | 60 words | The same script, for the rows written after the wiki reached format 3 (D161). Earlier rows are not checked or changed |

## Format of a skill

The format of a skill, its writing rules, and the format of its evaluation cases live in one place: [`plugin/skills/write-skill/references/style-guide.md`](../../../plugin/skills/write-skill/references/style-guide.md), the file the agent reads when it writes or audits a skill (D48, unit U5). In short: the front matter holds `name` and `description`, plus `context` and `agent` when the skill runs in a separate context (TD10), or plus `disable-model-invocation: true` when only the owner starts the skill (D141), and the body has up to five sections (When to use, Rules, Steps, Output, References).

That file repeats the numbers of L2 and L3, and `scripts/verify.sh` holds all four. A change to a limit changes the three places.

## Format of an agent file and the model configuration

An agent file is `plugin/agents/<name>.md` (TD7, TD8, TD11). Its front matter holds `name`, `description` (one line, within L3), `tools` (comma-separated, optional), `skills` (optional: the skills of the plugin that the agent preloads, on one line, separated by commas; D159), `model`, and `effort`. The body is the agent's system prompt: plain imperative rules, under about 150 words. Claude Code lists every agent with its description at session start, so agent descriptions count toward L4.

The `model` and `effort` lines are written from `plugin/models.conf` by `scripts/set-models.sh` and never edited by hand. The file has one line per agent: name, model, effort, with `#` for comments. A model is `haiku`, `sonnet`, `opus`, `fable`, `inherit`, or a full id starting with `claude-`. An effort is `low`, `medium`, `high`, `xhigh`, or `max`. `scripts/verify.sh` runs `set-models.sh --check` and fails when an agent file differs from the configuration, when a configured agent has no file, or when an agent file has no line.

## Format of the rules file

One line per rule, under five headings. No sources, no status, no numbers of decisions: those stay in [rules.md](rules.md).

## What changes from the installed style guide

| Installed guide | This guide | Why |
|-----------------|------------|-----|
| Limits in tokens | Limits in words and characters | A shell script can count them (F10) |
| Front matter also requires licence, author, and version | `name` and `description`, plus `context` and `agent` for a skill that runs in a separate context | The plugin declares no version yet (TD3); the rest belongs to the plugin manifest |
| Seven required sections | Five, each optional when empty | Fewer words loaded (F1) |
| Rules about the gentle-ai skill registry | None | The product does not depend on it (D28) |
| Two identical copies of the guide | One copy, inside the skill of U5 | One fact, one place (F2) |
