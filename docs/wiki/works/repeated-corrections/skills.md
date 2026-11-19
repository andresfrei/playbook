# Working skills for repeated-corrections

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed for this work. One skill is part of what the work builds: the criteria of repeated-corrections-7.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| `evidence.sh`, the hook at `SubagentStart`, the check added to `review-ran.sh`, and their tests, in POSIX shell and awk (N1, N2, N4) | No skill needed | `shellcheck`, `scripts/verify_test.sh`, and `scripts/verify.sh`, as earlier hooks of `playbook-agents` | Run them on each change |
| The classifier agent and its criteria skill (N3, repeated-corrections-7, -11) | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Write the criteria skill, within L2, with its evaluation cases, and preload it in the agent with `skills:`, as `review` preloads `review-change` |
| Hooks every project with `playbook-agents` runs at each `write` and `review`: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that each unit adds only what was decided |
| Claude Code's hooks and nested subagents | No skill needed | The sources of [technology.md](technology.md), and the `claude-code-guide` agent | When a behaviour is not documented there |
| `evidence-rules.md`, `format.md`, the READMEs, and the wiki | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Write the pages and the shared pages at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |

Names proposed: the agent `classify`, with model `sonnet` in `models.conf`, and the skill `classify-evidence`.
