# Working skills for seed-evidence

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| `seed-reviews.sh` and its tests, in POSIX shell and awk (N1, N2) | No skill needed | `shellcheck`, `scripts/verify_test.sh`, and `scripts/verify.sh` | Run them on each change |
| The command `seed-evidence` (N3) | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Write the skill within L2, with its evaluation cases |
| A script that reads private transcripts and a command that writes in other repositories: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that each unit adds only what was decided |
| The READMEs and the wiki | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | The shared pages at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
