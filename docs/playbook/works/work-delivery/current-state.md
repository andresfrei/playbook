# Current state for work-delivery

What exists on 2026-11-18, at commit 8a90471, about how a work's units are delivered. Checked by reading the files named; nothing was run.

| Path | What it says today |
|------|--------------------|
| `plugins/playbook-wiki/skills/prepare-project/references/5-plan.md` | Step 5 asks whether each unit is built on its own branch or on the main branch, whether a unit reaches the main branch by a pull request or a local merge, and whether independent units may be built in parallel. "Project already started" proposes the delivery the history shows. The closing condition asks that "how a unit is delivered is decided". |
| `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md` | Step 2 delivers each unit "as the plan says: its branch, and how it reaches the main branch". The close of the work has no step for a test branch. |
| `plugins/playbook-wiki/format.md` | "A work is what one branch carries from its start to its merge." |
| `plugins/playbook-agents/rules.md` | R14: push, pull requests, and merges are the owner's decisions. R15: about 400 changed lines is a planning guide, not a cap (D14). |
| `docs/wiki/01-product/skill-set.md` | Splitting large pull requests is dropped (D66); gentle-ai's `chained-pr` was rejected because it "treats 400 lines as a hard gate, against D14". |
| `plugins/playbook-wiki/evals/` | No case covers delivery. |

## What is missing

- A question about where changes are tested and where a work's units integrate.
- Reading the project's own skill for delivery.
- A default convention for branch names.
- A close of the work that waits for the test branch, when there is one.
