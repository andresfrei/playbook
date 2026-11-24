# wiki

The wiki is the folder `docs/playbook/` that a project gets when it adopts the playbook. It holds only what the code does not say: the product, the decisions, and the open work.

## What it holds

- `README.md`: the product in two lines, the owner, the open work, the pages, and the line `Last audit:`. It loads at the start of every session ([session-start](session-start.md)).
- Shared pages: `product.md`, `technology.md`, `skills.md`, and `design.md` when the project has an interface. Each statement cites its decision, or is marked Open. `technology.md` may hold the lines `Delivery default:` and `Versioning:`.
- `works/<work>/spec.md`: what and why, out of scope, the check, and the units of one change, with the lines `Status:`, `Delivery:`, and `Learned:` where they apply.
- `works/<work>/decisions.md`: a table with five columns, `| ID | Date | Decision | Who decided | Their words |`. IDs are `<work>-<n>`; "Their words" holds the owner's own text.
- `works/audit-<date>/decisions.md`: where an audit records answers when no work is open.

## Who writes it

- [define](define.md) creates a work and its spec; [close](close.md) writes what a work decided into the shared pages; [audit](audit.md) builds the wiki on a project's first run and keeps it true to the code; [audit-learning](audit-learning.md) marks works `Learned:`.

## The check

- `check-wiki.sh` checks that every relative link resolves (in shared pages and in works that have a `spec.md`), that every decision ID is unique, that every decision has the decider's words, and that no shared page cites a decision marked "Replaced by". It prints one FAIL line per problem and exits 1 on any.
- The skills run it, and the hook [commit-check](commit-check.md) runs it before a commit that changes `docs/playbook/`.

## Connects to

- [session-start](session-start.md), [adopt](adopt.md), [commit-check](commit-check.md).
- [define](define.md), [close](close.md), [audit](audit.md), [audit-learning](audit-learning.md).
- [rules](rules.md).

Source: [plugins/playbook/scripts/check-wiki.sh](../../plugins/playbook/scripts/check-wiki.sh)
