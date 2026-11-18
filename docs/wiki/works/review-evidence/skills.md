# Skills of review-evidence

Stage 3. One row for each technology of [technology.md](technology.md). Every skill named already lives in this repository; none is installed or written.

| Technology | Skill | Where it lives | When it is used |
|------------|-------|----------------|-----------------|
| N4: the runs in `claude plugin eval` and in `claude -p` with an empty `CLAUDE_CONFIG_DIR` | No skill needed | | The way a case runs is written in [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md); the runs with the rule, in [technology.md](technology.md) |
| N5 to N7: the cases, their `fixture.sh`, and the seeded patches | `write-skill` | `plugins/playbook-agents/skills/write-skill/` | Writing each case, as the section "Evaluation cases" of its style guide describes |
| N8: reading the replies | No skill needed | | The reading is written in N8 of [technology.md](technology.md); the agent `explore` may read the kept replies to save context |
| N9: the count for R20 with `jq` | No skill needed | | A local reading; the steps go in the plan |
| The wrapper `review-change` and the rule in `CLAUDE.md`, if the measurement justifies them (review-evidence-8) | `write-skill` and `keep-minimal` | `plugins/playbook-agents/skills/write-skill/`, `plugins/playbook-agents/skills/keep-minimal/` | Rewriting `review-change` within the limits of its style guide, and keeping the wrapper the simplest that works |
| The format of `playbook-wiki` for the rule in `CLAUDE.md`, and the shared pages at the close | `write-docs` | `plugins/playbook-wiki/skills/write-docs/` | Writing what the work decided in `plugins/playbook-wiki/format.md` and the shared pages |
