# Definition of the work skill-best-practices

## The problem

The format of a skill and the way it is checked live in `plugins/playbook-agents/skills/write-skill/references/style-guide.md` (D48), summarized in [../../01-product/style-guide.md](../../01-product/style-guide.md); how a skill is evaluated is in [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) (TD4). The owner asked, on 2026-11-17, whether `write-skill` follows two published guides. It follows their core and leaves out several of their practices.

Sources, read on 2026-11-17:

- Anthropic, "Skill authoring best practices": https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- agentskills.io: https://agentskills.io/skill-creation/best-practices, https://agentskills.io/specification.md, https://agentskills.io/skill-creation/evaluating-skills.md, https://agentskills.io/skill-creation/optimizing-descriptions.md

## What the style guide already has

One job per skill; instructions, not explanations; one word for one thing; detail in reference files, each listed with when to read it; a check run until it passes. Its limits are stricter than both guides: 700 words for the body, where they give 500 lines or 5,000 tokens, and 250 characters for the description, where they give 1,024. These stay.

## The gaps

skill-best-practices-1 decides which are adopted: G1, G3 to G7, G8 within G1, and G2 on one model per skill. G9 is not.

| # | What the guides say | What the style guide does |
|---|---------------------|---------------------------|
| G1 | Evaluations of behaviour: at least three cases, each run with the skill and without it, written before the skill's text (both guides) | Two cases that check only whether the skill loads (TD4) |
| G2 | Test with each model the skill runs on: Haiku, Sonnet, Opus (Anthropic) | Not asked |
| G3 | A list of gotchas, the mistakes the agent makes without the skill; "the highest-value content in many skills" (agentskills.io) | No such section |
| G4 | `name`: at most 64 characters, no leading, trailing, or double hyphen, not `anthropic` or `claude` (both) | Lowercase letters, digits, and hyphens only |
| G5 | References one level deep from `SKILL.md`; a table of contents in a reference file over 100 lines (Anthropic) | Not said |
| G6 | A default, not a menu of options; strictness matched to how fragile the task is; concrete examples of input and output (both) | Not said |
| G7 | Scripts with no interactive prompt, a `--help`, clear errors, data on stdout and diagnostics on stderr, documented exit codes (agentskills.io) | Not said |
| G8 | Content from real expertise and the project's own material, not generic knowledge (agentskills.io) | Not said |
| G9 | The description in third person, saying what and when (Anthropic); agentskills.io asks for "Use this skill when…" and its own example is in third person | It starts with the requests that trigger the skill, then says what it does |

Checked by running, on 2026-11-17: `claude plugin eval --help` (Claude Code 2.1.326) offers a run without the plugin as a baseline (`--ablation with-without`, the default), a judge model for `llm` graders (`--judge-model`, default `haiku`), and `--model` to run every case on one model. G1 and G2 need no new tool.

## What the work must do

- Add to the style guide and to `write-skill` the gaps adopted: G1, G3 to G7, G8 as one line of G1, and G2 as a run on the model each skill runs on (skill-best-practices-1).
- Audit each of the seven skills, `prepare-project`, `write-docs`, `doctor`, `keep-minimal`, `review-change`, `write-skill`, and `avoid-generic-design`, against the new rules, fix what they break, and give each its cases of behaviour (skill-best-practices-2).
- Audit the eighth skill, `init`, the same way, with no cases of behaviour (skill-best-practices-5).
- Measure the cost of the cases first, on `write-skill` under USD 2, and set the ceiling of the rest from it; run a paid evaluation only when the owner asks (skill-best-practices-3).

## What the work must not do

- Raise the limit of a skill's body, 700 words, or of its description, 250 characters (skill-best-practices-1).
- Change how a description is written, G9 (skill-best-practices-1).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above; the owner, and whoever writes a skill with `write-skill` |
| Who uses it | Covered: the agent that writes or audits a skill |
| Main flows | Covered: writing a new skill, and auditing or fixing one, the two flows of `write-skill` |
| What it must do | Covered: skill-best-practices-1, -2 |
| What it must not do | Covered: skill-best-practices-1 |
| Qualities | Covered: the limits of [../../01-product/style-guide.md](../../01-product/style-guide.md) stay (skill-best-practices-1); a gotchas section is in the body, which loads only with the skill, so what loads at session start does not grow |
| Limits | Covered: skill-best-practices-3 |
| Outside systems | Covered: `claude plugin eval` and Anthropic's models |
| Volume | Covered: eight skills in three plugins, seven with cases of behaviour |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: the style guide's terms |
