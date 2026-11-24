# Spec of the work context-measure

Status: Accepted (context-measure-3)

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (context-measure-1)

The audit ends by telling the owner to run `/context` for the real numbers, and the owner copies and pastes them back. Claude Code prints the same report in non-interactive mode: `claude -p "/context"` in the project gives the load of a fresh session by category (system prompt, tools, MCP, custom agents, memory files, skills), with no messages of the owner's session. The setup part's explorer already runs `claude -p "/skill-doctor"` (skill-usage-1); it runs `/context` the same way.

## What changes

In the skill `audit`:

1. **The explorer measures.** In the setup part, after `startup-context.sh` and `/skill-doctor`, the explorer runs `claude -p "/context"` in the project, a command that reads, and returns its table of categories and its lists of memory files, skills, and custom agents with their tokens. These numbers are not findings: no threshold of the playbook's own (one-audit-3).
2. **The main session shows them.** The output of the audit gives the table of categories when the setup part ran, in place of the advice to run `/context`; step 7 goes. When the setup part did not run, or the report failed, the output still advises `/context`.
3. **The model stays.** `auditor` keeps no `model:` line (context-measure-2).

And the line of `product.md` that says what the setup part reads.

## Out of scope

- A new agent, or one of this repository only.
- Hiding Claude Code's built-in skills, which `/skill-doctor` does not list.
- The context of the owner's own session: `claude -p` measures a fresh one.

## Check

- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook` and `claude plugin validate .`.
- Live check: `/playbook:audit setup` in this repository shows the table of categories with no `/context` asked of the owner.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| U1 | The setup part and the output of `audit` as above, and the line of `product.md` | The checks above | Done |
