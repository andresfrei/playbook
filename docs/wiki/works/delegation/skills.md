# Working skills for delegation

The skills the agent uses to build this work, one row per technology or task decided in [technology.md](technology.md). Every skill below is already in this repository; none is installed or written for this work.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| The text of `prepare-project` and of the doctor's `references/format-5.md`, and their evaluation cases (N6, N7, N8) | `playbook-agents:write-skill` | [Skill](../../../../plugins/playbook-agents/skills/write-skill/SKILL.md) | Write the reference files in the fixed format and within the limits |
| Keeping the change short | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Check that the change adds only what delegation-1 to -11 decided |
| The check in shell and awk, its mode `--delegations`, and format 5 (N4, N8) | No skill needed | `shellcheck`, and the tests of the check, as earlier changes to `check-wiki.sh` | Run `shellcheck` and `scripts/verify.sh` on each change |
| The contract, the format, the check, and the doctor, which every project uses: risky by R20 | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review each unit before delivery |
| `claude plugin eval` | No skill needed | [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) | Run the cases as that page says, only when the owner asks for a paid run |
| Wiki and documentation, the page `01-product/delegations.md` (N5) | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Write the shared pages and the glossary at the close |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, check the wiki, and close stages |
