# Working skills for parallel-units

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| The references of stages 5 and 6 of `prepare-project` (N5) | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Change the references within the style guide, keep `SKILL.md` within L2, and add evaluation cases under `plugins/playbook-wiki/evals/prepare-project-*` |
| git worktrees, branches, and merges (N1, N2, N4) | No skill needed | `git` | The commands are written in the references |
| Several `write` agents at once (N3) | No skill needed | Claude Code's Agent tool | The calls are written in the references |
| A change to the method that every project using `playbook-wiki` follows: an interface others use, risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that each unit adds only what was decided |
| The wiki and the shared pages | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | The shared pages at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
