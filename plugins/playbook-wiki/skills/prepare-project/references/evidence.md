# Evidence at the close of a work

Turn repeated findings of `review` into a rule one level up (repeated-corrections-5, -12, -13).

## When

At the close of a work, when `docs/wiki/evidence.md` exists. Skip silently otherwise.

## Steps

1. Locate `evidence.sh` using the client's working-agent instructions. If the agents plugin is unavailable, tell the owner and skip the rest of this file. Run subsequent commands from the project root with the quoted absolute script path.
2. Run `sh <script> count docs/wiki`. Each line "ready to consolidate: <kind> (level N): R distinct reviews, last DATE" is one group: kind K at level k. With no such line, go to step 7.
3. For each group, write one rule of level k+1 that covers every level-k Evidence row of K:
   - concrete, with an example inside;
   - says when it applies: which files or which kind of change;
   - cites its source as "<R> reviews, <first date> to <last date>".
4. Propose it to the owner, one group at a time, with the rows it replaces. When a delegation in force covers the kind `consolidate`, do not ask: do step 5 and say so in one line.
5. On a yes, or under a delegation: in Kinds, set the Level of K to k+1 and its Rule, Applies when, and Source. Delete the level-k Evidence rows of K; git keeps them. Run `sh <script> check docs/wiki`.
6. Record a decision of kind `consolidate` in the work's `decisions.md`: as recommended, changed, or rejected, or delegated; its shared page is "none". A rejected proposal keeps its rows; do not propose the same group again in this work.
7. For a kind with Scope `general` at level 2 or up, consolidated or not, leave out one whose Source is `evidence-rules.md` and one the owner already declined to send up. When `plugins/playbook-agents/evidence-rules.md` exists in this repository, propose adding the rule there; otherwise tell the owner that it can go up to the playbook (repeated-corrections-20), as a proposal the owner carries. Record the answer as a decision of kind other, so a declined proposal is not made again.

## Rules

- Never consolidate across levels or kinds.
- Never weaken a rule into something vague.
