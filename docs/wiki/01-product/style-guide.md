# Style guide

The format of the product's rules file and skills, and the size limits the verify script enforces (D32, TD4). Unit U1 of the [plan](../05-plan/plan.md). The owner accepted it (Decided: D48). Since phase 4 the limits L1 and L4 are counted for each plugin (D199).

## Limits

Limits are counted in words and characters, not tokens, because the verify script is plain shell (TD2) and can count those exactly.

| # | What | Limit | Today, measured 2026-11-13 |
|---|------|-------|-----------------------------|
| L1 | The file a plugin prints at the start of every session | `playbook-wiki`, the contract: 250 words. `playbook-agents`, the rules: 400 words (D199). It was 500 words for one rules file (D48) | On 2026-11-16 the contract has 249 words and the rules 399. Claude Code cuts what a hook prints at 10,000 characters, about 1,500 words, and measures each hook's text on its own |
| L2 | The body of a skill file, without its front matter | 700 words | The installed style guide sets 1,000 tokens, about 750 words. The seven skills the product starts from run from 344 to 664 words |
| L3 | A skill description | 250 characters | The installed style guide sets 250. The 43 installed skills have a median of 255 and a maximum of 767. Claude Code cuts at 1,536 |
| L4 | Everything a plugin loads at session start: its file of L1 plus the descriptions of its skills and agents | `playbook-wiki`: 350 words. `playbook-agents`: 620 words (D199). It was 800 words for the whole product (D48) | On 2026-11-16 `playbook-wiki` loads 337 words and `playbook-agents` 609. A person with the whole product loads 946, where the one plugin loaded 790. On 2026-11-13, before the product, about 15,400 words loaded |

The limits of L4 leave little room on purpose: adding a skill or a rule means removing or shortening something.

Why the whole product loads more than before (D199): the contract says what no file said while one person wrote the wiki, who decides when there are several people, the two layers of a wiki, and the step at the merge. It holds only what applies in every session; the detail of the format is read when a wiki is written, and the list of the step at the merge is given by a hook when a merge is about to run (TD28).

What Claude Code's documentation says of these sizes, read on 2026-11-16. It sets no limit in words for what a plugin loads. For a `CLAUDE.md` file: "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence." ([Memory](https://code.claude.com/docs/en/memory.md)) In general: "every line in it takes a little of Claude's attention on *every* task, whether it's relevant or not." ([Best practices](https://code.claude.com/docs/en/best-practices.md)) Taken from a summary of the pages, not from their own text: the list of skill descriptions has a budget of 1% of the model's context window, and a body of `SKILL.md` should stay under 500 lines.

A file over a limit fails the verify script. Text that does not fit moves to a reference file, which loads only when the skill needs it.

## Limits of a project's wiki

Two limits apply to a project's wiki, not to the plugin (D138). They are stated in the format of a wiki, [`plugins/playbook-wiki/format.md`](../../../plugins/playbook-wiki/format.md) (D201); why they exist is in [wiki-maintenance.md](wiki-maintenance.md).

| What | Limit | Enforced by |
|------|-------|-------------|
| The section "Where work stands" of a work's `README.md` | 250 words | `plugins/playbook-wiki/check-wiki.sh`, which also fails on a relative link that does not resolve and on a path the wiki names as code that does not exist (D160) |
| The text of a decision in a work's `decisions.md` | 60 words | The same script (D161). The `decisions.md` of an earlier format is history: the script does not read it (D202) |

## Format of a skill

The format of a skill, its writing rules, and the format of its evaluation cases live in one place: [`plugins/playbook-agents/skills/write-skill/references/style-guide.md`](../../../plugins/playbook-agents/skills/write-skill/references/style-guide.md), the file the agent reads when it writes or audits a skill (D48, unit U5). The work skill-best-practices added to it what Anthropic's and agentskills.io's guides have and it lacked. The limits of L2 and L3 stay as they are (skill-best-practices-1). In short:

- Front matter: `name` and `description`, plus `context` and `agent` when the skill runs in a separate context (TD10), or plus `disable-model-invocation: true` when only the owner starts the skill (D141).
- Name: at most 64 characters, lowercase letters, digits, and single hyphens, never the word `claude` or `anthropic` (skill-best-practices-1, -6). `scripts/verify.sh` fails on a name that breaks it.
- Files: references are one level deep, so a reference file names no other file of `references/`, and one over 100 lines opens with `## Contents` (skill-best-practices-1, -6). `scripts/verify.sh` fails on either.
- Body: up to six sections, in order: When to use, Rules, Gotchas, Steps, Output, References. Gotchas is optional: the mistakes the agent makes on the job without the skill, each with the right way (skill-best-practices-1). A skill at the limit moves its least-used detail to a reference file to make room for it (skill-best-practices-6).
- Writing: from the project's own material and tasks done, not generic knowledge; one default, with an alternative only with the case that calls for it; strictness matched to how fragile the step is; a concrete example where a format matters (skill-best-practices-1). No script can judge these: the audit with `write-skill` and the owner's review do (skill-best-practices-6).
- Scripts: no prompt, `--help`, result on standard output and messages on standard error, one documented exit code per kind of failure, errors that say what to do (skill-best-practices-1).
- Evaluation cases, two kinds (skill-best-practices-1, -6): two of triggering, one that must load the skill and one that must not; three of behaviour, which show the agent does the job better with the skill than without it. A skill only the owner starts gets the cases of behaviour alone; a skill whose run would change the person's settings gets none, as `init` (skill-best-practices-5). A new skill starts from its cases of behaviour. How they are run is in [skill-evaluation.md](../03-technology/skill-evaluation.md).

That file repeats the numbers of L2 and L3, and `scripts/verify.sh` holds all four. A change to a limit changes the three places.

## Format of an agent file and the model configuration

An agent file is `plugins/playbook-agents/agents/<name>.md` (TD7, TD8, TD11). Its front matter holds `name`, `description` (one line, within L3), `tools` (comma-separated, optional), `skills` (optional: the skills of the plugin that the agent preloads, on one line, separated by commas; D159), `model`, and `effort`. The body is the agent's system prompt: plain imperative rules, under about 150 words. Claude Code lists every agent with its description at session start, so agent descriptions count toward L4.

The `model` and `effort` lines are written from `plugins/playbook-agents/models.conf` by `scripts/set-models.sh` and never edited by hand. The file has one line per agent: name, model, effort, with `#` for comments. A model is `haiku`, `sonnet`, `opus`, `fable`, `inherit`, or a full id starting with `claude-`. An effort is `low`, `medium`, `high`, `xhigh`, or `max`. `scripts/verify.sh` runs `set-models.sh --check` and fails when an agent file differs from the configuration, when a configured agent has no file, or when an agent file has no line.

## Format of the rules file

Each of the two files holds one line per rule, under headings: the rules of `playbook-agents` under five, the contract of `playbook-wiki` under four (D175). No sources, no status, no numbers of decisions: those stay in [rules.md](rules.md).

## What changes from the installed style guide

| Installed guide | This guide | Why |
|-----------------|------------|-----|
| Limits in tokens | Limits in words and characters | A shell script can count them (F10) |
| Front matter also requires licence, author, and version | `name` and `description`, plus `context` and `agent` for a skill that runs in a separate context | The plugin declares no version yet (TD3); the rest belongs to the plugin manifest |
| Seven required sections | Five, each optional when empty | Fewer words loaded (F1) |
| Rules about the gentle-ai skill registry | None | The product does not depend on it (D28) |
| Two identical copies of the guide | One copy, inside the skill of U5 | One fact, one place (F2) |
