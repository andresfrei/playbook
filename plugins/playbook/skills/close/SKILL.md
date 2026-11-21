---
name: close
description: Close a work when it is built, or a unit of it. Checks the build against its spec, has the reviewer read a risky change, proposes one line for each repeated mistake, and updates the wiki's shared pages.
---

## When to use

- The owner says a work, or a unit of it, is built and asks to close it, finish it, or check it before delivery.

Do not use it for a small change with no work: run its tests and commit.

## Rules

- Ask one question at a time, with a recommendation, then stop and wait.
- Change nothing the owner has not accepted. A finding is fixed only when it affects correctness.
- Push, pull requests, merges, and releases are the owner's decisions.

## Steps

1. Read the work's `spec.md` and run the check it names for what is being closed. Report what fails and stop until it passes.
2. When the change is risky (stored data, security, an interface others use, concurrency, delivery, untested code), write the diff to a file in the scratchpad and give the agent `reviewer` the spec's path and that file. Show its findings; fix each one the owner accepts, and run the check again.
3. **Learning.** List each mistake of this work that happened twice, each correction the owner had to repeat, and each finding Claude should have known about the project. For each, propose one concrete line and where it goes:
   - the project's `CLAUDE.md`, for what holds in every session;
   - `.claude/rules/<topic>.md` with `paths:`, for one part of the code;
   - a skill's gotchas, for a procedure.
   Write each line the owner accepts. When there is none, say so in one line.
4. For a unit, mark it done in `spec.md`. For the whole work, write what it decided into the shared pages (`product.md`, `technology.md`, `skills.md`, `design.md`), each statement citing its decision, and clear the open work in `docs/wiki/README.md`.
5. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/wiki` and fix what it lists.
6. For the whole work, recommend whether it needs a new version, MAJOR, MINOR, or PATCH by Semantic Versioning, and ask the owner. On a yes, the owner runs `/playbook:release`.

## Output

- The check's result, the reviewer's findings and what was fixed, the lines proposed and accepted, the pages changed, and the version recommended.
