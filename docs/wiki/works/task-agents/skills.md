# Working skills for task-agents

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| `tasks.sh` and its tests, in POSIX shell and awk (N1) | No skill needed | `shellcheck`, `scripts/verify_test.sh`, and `scripts/verify.sh` | Run them on each change, under gawk and mawk |
| The close step and `references/tasks.md` of `prepare-project` (N2, N4) | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Change the references within the style guide, with a case of behaviour under `plugins/playbook-wiki/evals/` |
| The agent file written in a project (N3) | No skill needed | The front matter of the agents of `playbook-agents` | Copy its format |
| A script that writes in a project's wiki, and a change to the method every project follows: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that each unit adds only what was decided |
| The wiki and the shared pages | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | The shared pages at the close |
