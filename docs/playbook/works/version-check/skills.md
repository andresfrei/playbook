# Working skills for version-check

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed or written for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| The hook `version-check.sh`, the change to `wiki-format.sh`, and their tests, in POSIX shell and awk (N1 to N8) | No skill needed | `shellcheck`, `scripts/verify_test.sh`, and `scripts/verify.sh`, as earlier hooks of `playbook-wiki` | Run them on each change |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that the change adds only what version-check-1 to -9 decided |
| A hook every project with `playbook-wiki` runs at the start of a session: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| Claude Code's hooks and plugin files | No skill needed | The sources of [technology.md](technology.md), and the `claude-code-guide` agent | When a behaviour is not documented there |
| The README of `playbook-wiki` and the wiki | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Write the table of hooks and the shared pages at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
