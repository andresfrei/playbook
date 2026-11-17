# Skill style guide

The files, format, limits, and writing rules of a skill, and the format of its evaluation cases.

## Contents

- Files
- Limits
- Name
- Front matter
- Body
- Writing
- Scripts
- Evaluation cases: cases of triggering, cases of behaviour, running them

## Files

```text
<skill-name>/
├── SKILL.md        # what the agent loads for the job
├── references/     # detail, read only when a step asks for it
│   └── <topic>.md
└── scripts/        # a script that a step runs
    └── <name>.sh
```

- The directory name is the skill's name.
- Create `references/` or `scripts/` only when there is a file to put in it.
- References are one level deep: `SKILL.md` lists every reference file, and a reference file names no other file of `references/`.
- A reference file over 100 lines opens with a section `## Contents` that lists its sections, so a partial read still shows what it holds.

## Limits

| What | Limit |
|------|-------|
| The body of `SKILL.md`, without its front matter | 700 words |
| The description | 250 characters |

Count both from the skill's directory:

```sh
# Words in the body
awk 'n >= 2; /^---$/ { n++ }' SKILL.md | wc -w

# Characters in the description
sed -n 's/^description: *//p' SKILL.md | tr -d '\n' | wc -m
```

Quotes around the description do not count. Text that does not fit moves to a reference file.

## Name

- At most 64 characters: lowercase letters, digits, and single hyphens between them. No hyphen at the start or the end, and no two in a row.
- Not the word `claude` or `anthropic`, alone or as a part between hyphens.
- Specific: say the job, such as `review-change`, not `helper` or `tools`.

## Front matter

```markdown
---
name: <skill-name>
description: <The requests that trigger the skill>. <What the skill does>.
---
```

- `name` and `description`, and no other key. A skill that runs in a separate context adds two more after them, both and in this order: `context: fork`, then `agent` naming the agent that runs it. Set no `model` or `effort`; the agent's own apply. A skill that only the owner starts adds one key after them instead: `disable-model-invocation: true`. Claude Code then keeps its description out of the session, so it does not count toward the limit at session start.
- `name` equals the directory name.
- The description is one line. It starts with the requests that trigger the skill, in the words the owner would use, then says what the skill does.

## Body

These sections, in this order. Leave a section out when it would be empty.

| Section | Contains |
|---------|----------|
| When to use | The situations that load the skill, and the ones that must not |
| Rules | What the agent must and must not do. Each one can be checked |
| Gotchas | The mistakes the agent makes on this job without the skill, each with the right way |
| Steps | The work, in order |
| Output | What the agent returns or writes |
| References | Local files with detail, and when to read each |

Template:

```markdown
## When to use

- <A situation that loads the skill>

Do not use it for <a similar situation that belongs to another job>.

## Rules

- <What the agent must or must not do>

## Gotchas

- <A mistake the agent makes>: <the right way>.

## Steps

1. <An action>

## Output

- <What the agent returns or writes>

## References

- `references/<topic>.md` — <what it holds>. Read it when <condition>.
```

A gotcha comes from a mistake seen: a case of behaviour that failed, or a correction the owner made. When the agent is corrected on the skill's job, add the mistake to Gotchas.

## Writing

- Write instructions, not explanations: "Read X", "Ask Y", "Return Z".
- Write each rule so that a reader can tell whether it was followed.
- Write from the project's own material and from tasks done: its documents, the owner's corrections, the failures seen. Leave out what the agent already knows.
- Give one default. Name an alternative only together with the case that calls for it.
- Match how strict a step is to how fragile it is. For a fragile operation, give the exact command and say not to change it; elsewhere, give the goal and let the agent choose the way.
- Where a format matters, show a concrete example of input and output.
- Keep history, reasons, and tutorials out of `SKILL.md`. Put what the agent needs in a reference file and leave the rest out of the skill.
- State each fact once. Elsewhere, point to it.
- Use one word for one thing. Do not vary a term for style.
- Write in English.
- Name no command, tool, or file that may be missing where the skill runs. When a step needs something that is not always there, say when the step applies.

## Scripts

A script in `scripts/`:

- Takes its input from arguments, the environment, or standard input. It never stops to ask.
- Prints its usage with `--help`, and on a wrong call.
- Writes its result to standard output and its messages to standard error.
- Exits 0 when it succeeds, and with a different code for each kind of failure, listed in its usage.
- Says in an error what went wrong and what to do.

`SKILL.md` says when to run each script, and whether to run it or read it.

## Evaluation cases

A skill gets two kinds of case:

| Kind | How many | Proves |
|------|----------|--------|
| Triggering | Two: one request that must load the skill, one similar that must not | The description loads the skill when it should |
| Behaviour | Three | The agent does the job better with the skill than without it |

A skill that only the owner starts gets the cases of behaviour and no cases of triggering. A skill whose run would change the person's settings outside the case's folder gets no cases; say why in the report to the owner.

For a new skill, write the cases of behaviour first, from tasks done and the project's own material, then write `SKILL.md` until they pass.

When the skill does not live in a Claude Code plugin, write the requests and what each must show in the report to the owner. When it lives in a plugin, write them as cases for `claude plugin eval`, under `<plugin>/evals/`, one folder per case:

```text
<plugin>/evals/
├── <skill-name>-triggers/
├── <skill-name>-does-not-trigger/
├── <skill-name>-<behaviour 1>/
├── <skill-name>-<behaviour 2>/
└── <skill-name>-<behaviour 3>/
```

### Cases of triggering

`prompt.md`, in both cases, with a request phrased as the owner would type it, without naming the skill:

```markdown
---
tags: [<skill-name>]
allowed_tools: [Read, Glob, Grep, Skill]
---

<The request>
```

`graders/skill-loaded.md`:

```markdown
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?<skill-name>"'
---
```

`graders/skill-not-loaded.md`:

```markdown
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?<skill-name>"'
min: 0
max: 0
arm: both
---
```

### Cases of behaviour

Each case is one real task of the skill's job. Make the three differ: a plain one, one with less detail or other words, and one at the edge of the job.

`prompt.md` holds the task, with the tag `<skill-name>-behaviour` and the tools the task needs:

```markdown
---
tags: [<skill-name>-behaviour]
allowed_tools: [Read, Glob, Grep, Skill, Write]
---

<The task>
```

 Each file in `graders/` checks one thing the result must show. Prefer a grader that costs nothing and reads what can be seen: a file written (`file_exists`), a text in the answer (`regex`), a tool called (`tool_used`). Use a grader that a model judges only for what needs reading, one criterion per file:

```markdown
---
type: llm
weight: 1
---

<What a correct result shows, in one checkable sentence>
```

The graders' fields are in Claude Code's documentation: https://code.claude.com/docs/en/plugin-evals.md.

A case that passes as well without the plugin proves nothing the skill adds: replace it.

### Running them

Run one skill's cases from the directory that holds the plugin, on the model the skill runs on: `sonnet` for a skill that runs in the session; a skill with `context: fork` runs on its agent's model.

```sh
# Triggering: no baseline arm, which does not score a Skill grader
claude plugin eval <plugin> --tag <skill-name> --ablation none --model sonnet --max-cost-usd <ceiling> --no-publish

# Behaviour: with the plugin and without it
claude plugin eval <plugin> --tag <skill-name>-behaviour --model sonnet --max-cost-usd <ceiling> --no-publish
```

A case of behaviour runs in an arm with the plugin and in a baseline arm without it. It passes when its graders pass in the arm with the plugin; the report also gives the baseline's score. The command exits 0 only when every case passes. Every run is a billed model call, and by default each case runs three times in each arm.
