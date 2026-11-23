---
name: close
description: Close a work when it is built, or a unit of it. Checks the build against its spec, has the reviewer read a risky change, proposes one line for each repeated mistake or decision, and updates the wiki's shared pages.
---

## When to use

- The owner says a work, or a unit of it, is built and asks to close it, finish it, or check it before delivery.

Do not use it for a small change with no work: run its tests and commit.

## Rules

- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer.
- Do each light step without asking, and ask each medium one, by the weights of the rules (R18). A finding is fixed only when it affects correctness.
- Push, pull requests, merges, and releases are the owner's decisions.

## Steps

1. Read the work's `spec.md`, whose line `Delivery:` says how it is delivered, and run the check it names for what is being closed. Report what fails and stop until it passes.
2. When the change is risky (stored data, security, an interface others use, concurrency, delivery, untested code), write the diff to a file in the scratchpad and give the agent `reviewer` the spec's path and that file. Show its findings. Fix each finding that breaks the spec or a recorded decision, a light step, and ask about each one that needs a choice they do not settle. Run the check again.
3. **Learning.** List each mistake of this work that happened twice, each correction the owner had to repeat, and each finding Claude should have known about the project. For each, propose one concrete line and where it goes:
   - the project's `CLAUDE.md`, for what holds in every session;
   - `.claude/rules/<topic>.md` with `paths:`, for one part of the code;
   - a skill's gotchas, for a procedure.
   Also list each decision of this work that repeats the answer of an earlier one, and propose the rule, or the delegation in the project's `CLAUDE.md`, that stops it being asked, citing both IDs.
   Write each line the owner accepts. When there is none, say so in one line.
4. For a unit, mark it done in `spec.md`, update the next unit in the line "Open work" of `docs/playbook/README.md`, and ask with `AskUserQuestion` whether to close here; the next unit is already written in the README, so on a yes commit and tell the owner to type `/clear` naming the next unit. Ask in both build modes: in `builder` the main session still grows with each brief and summary (session-cost-1, session-cost-8, build-mode-6, ask-to-clear-1). For the whole work, write what it decided into the shared pages (`product.md`, `technology.md`, `skills.md`, `design.md`), each statement citing its decision, and clear the open work in `docs/playbook/README.md`. For each decision of the work that starts with "Replaces <ID>", write "Replaced by <its ID>" at the start of the old decision's cell and move each shared page's citation of the old ID to the new one, in the same edit. Reread each shared page you changed against the work's decisions, and show any contradiction to the owner to resolve.
5. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and fix what it lists.
6. For the whole work, read the line "Last audit" in `docs/playbook/README.md`. When works closed since then, there is none, or you found a contradiction, offer in one line to run the skill `audit-wiki`, and run it on a yes (agent-runs-skills-1).
7. For the whole work, offer in one line to run the skill `audit-learning`, which looks for what repeats across works, and run it on a yes (cross-work-learning-4).
8. For the whole work, read the line `Versioning:` of `docs/playbook/technology.md` (delivery-versioning-3). When it says never, say so and recommend no version. When it says after several works together, recommend one only if the owner asked. Otherwise, or with no line, recommend whether the work needs a new version, MAJOR, MINOR, or PATCH by Semantic Versioning, and ask the owner. On a yes, run the skill `release` with that version (agent-runs-skills-1).

## Output

- The check's result, the reviewer's findings and what was fixed, the lines proposed and accepted, the pages changed, whether `audit-learning` ran, and the version recommended.
