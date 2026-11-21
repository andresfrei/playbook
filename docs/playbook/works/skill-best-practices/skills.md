# Skills of skill-best-practices

Stage 3. One row for each technology of [technology.md](technology.md). No skill is installed or written beyond the ones this work changes.

| Technology | Skill | Where it lives | When it is used |
|------------|-------|----------------|-----------------|
| N1, N2: cases of `claude plugin eval` | `write-skill` | `plugins/playbook-agents/skills/write-skill/` | Writing the cases of each skill, once its style guide holds the format of a case of behaviour |
| N3, N4: checks in `scripts/verify.sh` | `keep-minimal` | `plugins/playbook-agents/skills/keep-minimal/` | Writing the checks and their cases in `scripts/verify_test.sh` |
| N5, N6: the text of the style guide and of each skill | `write-skill` | `plugins/playbook-agents/skills/write-skill/` | Auditing and fixing each of the eight skills |
| The shared pages of the wiki at the close | `write-docs` | `plugins/playbook-wiki/skills/write-docs/` | Rewriting `01-product/style-guide.md` and `03-technology/skill-evaluation.md` |
| A change to `verify.sh` | `review-change` | `plugins/playbook-agents/skills/review-change/` | Reading the change before it is Done, since a wrong check fails every later change (R20) |
