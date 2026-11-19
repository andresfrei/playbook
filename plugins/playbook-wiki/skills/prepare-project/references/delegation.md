# Delegation

The owner decides per case or by a recorded delegation (R6). A delegation covers one kind of decision in this project, and the agent decides that kind without asking. Kinds and answers are listed in `../../../format.md`, under "A work's `decisions.md`".

## Never delegated

- A new definition of the product.
- A push, or a merge into the main branch.
- An action outside the repository or on the owner's machine.
- Spending beyond a written ceiling.

## Before a question

1. Name the kind of the decision you are about to ask for.
2. A delegation is in force when `docs/wiki/01-product/delegations.md` lists it among the delegations in force, or a row of the current work's `decisions.md` made it, and no row of the current work's `decisions.md` revokes it.
3. Ask, as the skill says, when no delegation in force covers the kind, or when the decision is one of "Never delegated".
4. Otherwise do not ask. Record the decision as a row of the work's `decisions.md`: "Who decided" is `agent, by <the delegation's identifier>`, the words are "none", and the answer is delegated. Then tell the owner in one line what was decided and under which delegation, such as "Closed stage 3 (delegation of auth-7)."

## When the owner answers

- Record the kind and the answer with the decision, as plain text without backticks: as recommended when the owner accepted the recommendation as it was; changed when they accepted and added or changed something; rejected when they said no.
- When the owner answers "yes but" or "no" about a decision taken by delegation, propose revoking that delegation. A revocation is a decision, in force from its row on.

## At the close of a work

1. Run `sh <this skill's folder>/../../check-wiki.sh --delegations docs/wiki`. It prints the kinds the owner accepted as recommended often enough.
2. Leave out a printed kind that a delegation in force already covers, that the owner already declined to delegate, or that is merge-push. For definition, a proposal covers only decisions that are not a new definition of the product.
3. Propose each kind left, once, with its numbers. Record the answer as a decision of kind other, yes or no, so a declined proposal is not made again.
4. When writing the shared pages, add each new delegation to `01-product/delegations.md`, and move each one revoked in this work to its table of delegations revoked, citing the decision that revoked it.
