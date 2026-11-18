# Skills of review-trigger

Stage 3. One row for each technology of [technology.md](technology.md). Every skill named already lives in this repository; none is installed or written.

| Technology | Skill | Where it lives | When it is used |
|------------|-------|----------------|-----------------|
| N1 to N8: the two hooks of `playbook-agents`, in `sh`, and their `hooks.json` | `keep-minimal` | `plugins/playbook-agents/skills/keep-minimal/` | Writing the hooks the simplest that meets N4 to N8, following the shape of `plugins/playbook-wiki/hooks/commit-check-hook.sh` |
| The hooks are an interface others use and run before every commit (R20) | `review-change` | `plugins/playbook-agents/skills/review-change/` | The agent `review` reads each unit that changes a hook before it is delivered |
| N9: the cases in `scripts/verify_test.sh` | No skill needed | | The cases follow those of `commit-check-hook.sh` in the same file |
| N10: the count again | No skill needed | | The method is written in [review-evidence-U1](../review-evidence/measurements.md) |
| The shared pages at the close: `03-technology/architecture.md`, `01-product/rules.md` | `write-docs` | `plugins/playbook-wiki/skills/write-docs/` | Writing what the work decided in the shared pages |
