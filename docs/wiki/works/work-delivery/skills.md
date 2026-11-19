# Working skills for work-delivery

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed or written for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| The text of `5-plan.md` and `6-execution.md` of `prepare-project`, and their two evaluation cases | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Write the reference files in the fixed format and within the limits, and the two cases |
| Keeping the step short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that the step adds only what work-delivery-1 to -9 decided |
| The change to `prepare-project`, which other projects use: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review the changed reference files before delivery |
| git and `gh` (N2, N3) | No skill needed | [technology.md](technology.md), with its sources | The commands are named there; a new one is checked in its `--help` |
| `claude plugin eval` (N5) | No skill needed | [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) | Run the two cases as that page says, only when the owner asks for a paid run |
| Wiki and documentation | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Update the shared pages and the glossary at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
