# Skills of skill-triggering

Stage 3. One row for each technology of [technology.md](technology.md). Every skill named already lives in this repository; none is installed or written.

| Technology | Skill | Where it lives | When it is used |
|------------|-------|----------------|-----------------|
| N1 to N3, N5: the measurements with `claude plugin eval` | No skill needed | | The way a case runs is written in [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) and [technology.md](technology.md) |
| The descriptions and gotchas of `review-change`, `keep-minimal`, `prepare-project`, and `avoid-generic-design` (skill-triggering-4) | `write-skill` | `plugins/playbook-agents/skills/write-skill/` | Changing the text of each skill, within the limits of its style guide |
| N6: `wiki-format.sh mark` and its case in `scripts/verify_test.sh` | `keep-minimal` | `plugins/playbook-agents/skills/keep-minimal/` | Writing the change to the script and its test |
| A change to `wiki-format.sh`, which writes the wiki's marker | `review-change` | `plugins/playbook-agents/skills/review-change/` | Reading the change before it is Done: a mistake there can leave a wiki without its marker (R20) |
| The shared pages of the wiki at the close | `write-docs` | `plugins/playbook-wiki/skills/write-docs/` | Writing what the work decided in `03-technology/skill-evaluation.md` |
