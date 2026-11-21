# Working skills for setup commands

Accepted in setup-commands-12. The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md) and [architecture.md](architecture.md). Every skill below is already in this repository; none is installed or written for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| The three new or changed skills: `/playbook:init`, `/playbook-wiki:init`, `/playbook-agents:config`, and the change to `prepare-project` | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Write each `SKILL.md` in the fixed format, within the size limits, with its two evaluation cases |
| POSIX `sh`, `sed`, and `awk` scripts and the `PreToolUse` hook | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Write `init.sh` changes, the config script, and the hook; test them on sample inputs |
| Claude Code hooks, settings files, and the Agent tool | No skill needed | [technology.md](technology.md), with its sources | Check against the documentation linked there; a new question goes to the `claude-code-guide` agent |
| The hook and the writes to the person's settings files: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit that writes a settings file or adds the hook, before delivery |
| Wiki and documentation | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Update the shared pages and the plugins' `README.md` at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
