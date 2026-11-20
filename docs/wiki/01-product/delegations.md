# Delegations

The kinds of decision the agent decides in this project without asking the owner (R6). Each one is a decision of a work, for one kind in this project; a later decision revokes it, and a "yes but" or a "no" on a decision taken by delegation leads the agent to propose revoking it (delegation-7). The agent still asks what is never delegated: a new definition of the product, a push or merge into the main branch, an action outside the repository or on the owner's machine, and spending beyond a written ceiling (delegation-5).

## In force

| Kind | What the agent decides | Decision |
|------|------------------------|----------|
| close-stage | Closes a stage when its closing condition holds and the check passes, records it as `agent, by delegation-16`, and tells the owner in one line | delegation-16 |
| consolidate | At the close of a work, consolidates each group of repeated findings that `evidence.sh count` marks ready into a rule one level up, records it as `agent, by ask-before-irreversible-22`, and tells the owner in one line | ask-before-irreversible-22 |
| open-work | When the owner asks for a work in their own words, opens it without asking, records those words as its origin, and tells the owner its name and scope in one line. Narrow: a work the agent proposes unasked is still asked | repeated-corrections-29 |

## Revoked

| Kind | Decision that made it | Decision that revoked it |
|------|-----------------------|--------------------------|

Proposed and declined, not proposed again: plan (delegation-17) and version (delegation-18).
