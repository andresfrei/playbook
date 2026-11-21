---
name: init
description: Add a wiki to a repository that has none, such as an old project or someone else's. Writes only the skeleton, the entry point with the project's owner and the format marker, and opens no work.
disable-model-invocation: true
---

## When to use

- The person types `/playbook-wiki:init` in a repository with no `docs/wiki/`.

Do not use it to repair a wiki that exists, which is `/playbook-wiki:migrate`, or to define a product, which is `prepare-project`.

## Rules

- Write only `docs/wiki/README.md`, `docs/wiki/.format` through the script, and, after a yes, the two sentences in `CLAUDE.md`.
- Open no work, and write no decision, question, or page other than the `README.md`.

## Steps

1. When `docs/wiki/README.md` exists, run `sh "${CLAUDE_SKILL_DIR}/../migrate/scripts/wiki-format.sh" status docs/wiki` from the project's root. When it prints a line, show it and point to `/playbook-wiki:migrate`; otherwise say the repository already has a wiki. Change nothing, and stop.
2. Read `${CLAUDE_SKILL_DIR}/../../skeleton.md` and do its steps.

## Output

- The files written, and the owner recorded.
- That the wiki has no work yet: `prepare-project` opens the first one when the person asks to define a product, a feature, or a phase.
