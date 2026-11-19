# Architecture of the work repeated-corrections

## The problem

`review` finds the same kinds of mistakes again and again, and nothing keeps what was learned: each finding is fixed and forgotten (see [measurements.md](measurements.md)). The work closes that loop inside the agent system, with no person counting by hand.

## Requirements and assumptions

- The cycle of repeated-corrections-9 runs first at `write` and `review` (repeated-corrections-14).
- Counting is done by a script, judging by a subagent with the model `sonnet` (repeated-corrections-6, -10).
- Hooks in POSIX `sh` and `awk`, as the plugins' other hooks; no network.
- Assumed: few rules per project, so all rules of level 2 and up fit in a subagent's context with no filter.

## The shape

Hooks around two existing agents and one new agent, with one page of data per project:

```text
write / review start ──SubagentStart──> evidence.sh rules ──> rules of level 2+ in their context
review ends with findings ──> starts classifier (sonnet) ──> adds evidence rows to docs/wiki/evidence.md
review ends ──SubagentStop──> no classifier started? stop it and ask for one
close of a work ──> evidence.sh count ──> kinds with 3 distinct reviews at one level ──> proposals to the owner
```

It fits the requirements because each judgement is made once by the classifier, each number by the script, and the step never needs the agent to remember.

## Modules

| Module | Responsible for | Does not | Used by |
|--------|-----------------|----------|---------|
| `evidence.sh` (`playbook-agents`) | Checks the page; counts distinct reviews per kind and level; prints the rules of level 2 and up of the project and of `evidence-rules.md` | Judge whether two findings are the same; write the page | The hook of N1, the classifier, the close of a work |
| Hook at `SubagentStart` (`playbook-agents`) | Gives `write` and `review` the rules | Filter by the task; it has no task | Claude Code |
| `review-ran.sh` at `SubagentStop` | Also stops a review that ended with findings and started no classifier | Classify | Claude Code |
| The classifier agent | Applies the criteria of repeated-corrections-11; adds rows; creates a kind when none fits | Consolidate without approval, unless `consolidate` is delegated | `review` |
| `evidence-rules.md` (`playbook-agents`) | The general rules | Hold evidence | `evidence.sh` |

## Main data

`docs/wiki/evidence.md` holds a table of kinds, with each kind's rule, its level, when it applies, and its source; and a table of evidence, one row per finding: kind, level, review, date, a general line. A consolidation replaces the evidence rows of one kind and level with a rule one level up; git keeps the rows removed. The exact columns are set in stage 3 with the criteria skill.

## Outside systems

Claude Code's hooks and nested subagents, checked on 2026-11-19 (see [technology.md](technology.md)). Critical: without nesting (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`), no evidence is stored.

## Risks

| Risk | What reduces it |
|------|-----------------|
| A vague rule spreads to every project | Consolidations approved by the owner (repeated-corrections-13); criteria point 5 |
| `review` forgets the classifier | The `SubagentStop` check |
| Two reviews write the page at once | The classifier only adds rows |
| `sonnet` judges poorly | Evaluation cases in stage 3; the model is a line of `models.conf` |
| Rules grow past a subagent's context | Consolidation removes rows; measure when rules pass a few dozen |

## Trade-offs

- Classifying at the end of each review gains evidence at once and costs one `sonnet` run per review with findings.
- No filter by task gains a simple hook and costs every rule in each start.
- Its own script, not the wiki's check, gains no new format and costs one more script.

## Discarded alternatives

- A queue classified at the close of a work: rules learned later (replaced by repeated-corrections-17).
- `PostToolUse` on `Agent`: misses reviews in the background.
- Hooks of type `prompt` or `agent`: they only allow or block, and the agent type is experimental.
- Rewriting the prompt at `PreToolUse` to filter rules: fragile, and little to save with few rules.

## How it can evolve

The stages of a work and the commits can run the same cycle (repeated-corrections-14); memory and lint can be sources (repeated-corrections-2); the tool of repeated-corrections-8 seeds a repository from its past reviews.
