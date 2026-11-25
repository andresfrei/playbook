# Spec of the work reference-docs

Status: Accepted (reference-docs-3)

Learned: 2026-11-25

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

An agent or a person who opens the repository on GitHub has to read the whole README to learn what Playbook is, how to install it, and what it touches; what each piece does is repeated, in different words, in the root README, the plugin's README, and each `SKILL.md`, so one copy goes stale (reference-docs-1). This work gives the repository one entry for agents and one reference, a page per piece, reached from one index.

## What changes

1. **Root README.** Under the title, a block "For AI agents" of about five lines: what Playbook is (a Claude Code plugin), the two install commands, the five commands, what it writes (`docs/playbook/`, lines proposed for `CLAUDE.md`), where the source is, and the link to the index. Then the README in this order: what it is, how a change goes (short, linking each piece's page), install, updates, and links to the reference. Every statement in it is checked against the plugin as it is now.
2. **Reference.** `docs/reference/README.md` is the index: one line per page, grouped as skills, agents, hooks, and concepts. One page per piece:
   - skills: `define`, `close`, `audit`, `audit-learning`, `release`;
   - agents: `builder`, `reviewer`, `auditor`;
   - hooks: `session-start`, `adopt`, `ask`, `commit-check`;
   - concepts: `rules`, `wiki`, `build-mode`, `sessions`, `permissions`, `upgrade-from-4`.

   A page of a piece says, in this order: what it is, when it runs, what it reads, what it writes, what it asks the owner, and which pieces it connects to, each linked. It describes behaviour, not the code; the source file is linked.
3. **Moves.** "Build mode" and "Why sessions are short" of `plugins/playbook/README.md` move to `build-mode.md` and `sessions.md`; that README keeps the plugin's one-line description, the install commands, and the link to the index. "From 4.x" and the permission rules of the root README move to `upgrade-from-4.md` and `permissions.md` (reference-docs-2).
4. **Check.** `tests/reference_test.sh` fails when a skill folder, an agent file, or a hook script other than `lib.sh` under `plugins/playbook/` has no page in `docs/reference/`, or when a page is not linked from the index.

## Out of scope

- An `llms.txt` on the site playbook.neuralmind.lat.
- Changes to the skills, agents, hooks, or rules themselves.
- The wiki in `docs/playbook/`, other than this work's folder and the line "Open work".

## Check

- `sh tests/reference_test.sh` passes, and fails when a page or an index line is removed.
- The checks of `CLAUDE.md`: the three tests, `check-wiki.sh docs/playbook`, `shellcheck` including the new test, and `claude plugin validate .`.
- `git grep` finds no link to a moved section's old place.
- A fresh agent, given only the repository URL's README, answers what Playbook is, how to install it, and what `close` does, from the block and one page.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| U1 | Point 2 and 4: the index, the 18 pages, and the test | `tests/reference_test.sh` and shellcheck | Done |
| U2 | Points 1 and 3: the root README with its block, and the plugin README as a link | The whole check above | Done |
