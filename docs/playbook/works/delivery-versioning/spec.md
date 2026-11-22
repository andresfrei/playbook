# Spec of the work delivery-versioning

Status: Accepted (delivery-versioning-4).

## What and why (session-cost-5, session-cost-6, session-cost-7)

No skill asks how a work is delivered or how a project is versioned. Evidence: `huellitas-id` ended works T3 and T4 with no tag and no versioning line in its `technology.md`; `release` falls back to guessing from the manifests. The playbook offers both as optional definitions the owner may leave Open, with no new skill.

Claude Code's documentation, read on 2026-11-22: common-workflows.md, "Run parallel sessions with worktrees": "Each git worktree is a separate checkout on its own branch", started with `claude --worktree <name>`.

## What changes

1. A project's `technology.md` holds two lines, each optional (delivery-versioning-1, -3):
   - Delivery default: one of three forms, or the owner's words: one branch and one pull request per work; one per unit; a worktree of its own for parallel sessions (delivery-versioning-2).
   - Versioning: what carries a version, where it is declared, and when a tag is made: after the merge of each work `close` recommends versioning; after several works together, when the owner asks; never (delivery-versioning-3).
2. `define` writes a line "Delivery" in each `spec.md`, copied from the project's default. It asks only when the project has no default or the work needs another way (delivery-versioning-1).
3. `close` and `release` read the Versioning line instead of guessing from the manifests; with none, they behave as today.
4. `audit-wiki` holds a short list of what every project with the playbook must have defined: the product and its owner, the technology and its versions, how a change is checked, the versioning policy, and the default way of delivery. It reports each item missing with a proposal to define it; the owner may leave it Open. An item is on the list only while a skill of the playbook reads it (session-cost-7).

## Out of scope

- A new skill, or a hook that enforces a delivery or a tag: the playbook asks and records, the owner decides.
- Pushing, merging, and tagging stay the owner's (R14).

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Change 1 to 3: `define` and `close`/`release` read and write the two lines; this repository's `technology.md` gets its Versioning line (already says it today) and a Delivery default | `check-wiki.sh` and the tests pass; `define` in a throwaway repository writes the Delivery line | Done |
| 2 | Change 4: the list in `audit-wiki` | `claude -p --plugin-dir plugins/playbook` on a throwaway repository with no versioning line reports it with a proposal | Done |

Both units merge before one new version is released (session-cost-5).
