# Skill style guide

The files, format, limits, and writing rules of a skill, and the format of its evaluation cases.

## Files

```text
<skill-name>/
├── SKILL.md        # what the agent loads for the job
├── references/     # detail, read only when a step asks for it
│   └── <topic>.md
└── scripts/        # a script that a step runs
    └── <name>.sh
```

- The directory name is the skill's name: lowercase letters, digits, and hyphens.
- Create `references/` or `scripts/` only when there is a file to put in it.

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

## Front matter

```markdown
---
name: <skill-name>
description: <The requests that trigger the skill>. <What the skill does>.
---
```

- `name` and `description`, and no other key. A skill that runs in a separate context adds two more after them, both and in this order: `context: fork`, then `agent` naming the agent that runs it. Set no `model` or `effort`; the agent's own apply. A skill that only the owner starts adds one key after them instead: `disable-model-invocation: true`. Claude Code then keeps its description out of the session, so it does not count toward the limit at session start, and the skill gets no evaluation cases.
- `name` equals the directory name.
- The description is one line. It starts with the requests that trigger the skill, in the words the owner would use, then says what the skill does.

## Body

These sections, in this order. Leave a section out when it would be empty.

| Section | Contains |
|---------|----------|
| When to use | The situations that load the skill, and the ones that must not |
| Rules | What the agent must and must not do. Each one can be checked |
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

## Steps

1. <An action>

## Output

- <What the agent returns or writes>

## References

- `references/<topic>.md` — <what it holds>. Read it when <condition>.
```

## Writing

- Write instructions, not explanations: "Read X", "Ask Y", "Return Z".
- Write each rule so that a reader can tell whether it was followed.
- Keep history, reasons, and tutorials out of `SKILL.md`. Put what the agent needs in a reference file and leave the rest out of the skill.
- State each fact once. Elsewhere, point to it.
- Use one word for one thing. Do not vary a term for style.
- Write in English.
- Name no command, tool, or file that may be missing where the skill runs. When a step needs something that is not always there, say when the step applies.

## Evaluation cases

A new skill gets two cases:

| Case | Request | Passes when |
|------|---------|-------------|
| Triggers | One the skill must answer, phrased as the owner would type it, without naming the skill | The agent loads the skill |
| Does not trigger | A similar one that belongs to another job | The agent does not load the skill |

When the skill does not live in a Claude Code plugin, write the two requests in the report to the owner.

When the skill lives in a Claude Code plugin, write them as cases for `claude plugin eval`:

```text
<plugin>/evals/
├── <skill-name>-triggers/
│   ├── prompt.md
│   └── graders/skill-loaded.md
└── <skill-name>-does-not-trigger/
    ├── prompt.md
    └── graders/skill-not-loaded.md
```

`prompt.md`, in both cases:

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

Run one skill's cases from the directory that holds the plugin:

```sh
claude plugin eval <plugin> --tag <skill-name> --max-cost-usd <ceiling>
```

The command exits 0 only when every case passes. Every run is a billed model call, and by default each case runs three times with the plugin and three times without it.
