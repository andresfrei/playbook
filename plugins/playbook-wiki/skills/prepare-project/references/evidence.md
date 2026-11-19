# Evidence at the close of a work

Turn repeated findings of `review` into a rule one level up (repeated-corrections-5, -12, -13).

## When

At the close of a work, when `docs/wiki/evidence.md` exists. Skip silently otherwise.

## Steps

1. Find the script `evidence.sh` of the sibling plugin `playbook-agents`. Run:

   ```sh
   cd "<this skill's folder>" && for p in ../../../playbook-agents/evidence.sh $(ls -d ../../../../playbook-agents/*/evidence.sh 2>/dev/null | awk -F/ '{ print $(NF-1) "\t" $0 }' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1 | cut -f2); do [ -f "$p" ] && (cd "$(dirname "$p")" && echo "$(pwd)/evidence.sh"); done | tail -n 1
   ```

   It prints the absolute path found: a marketplace from a folder, or the highest version of an installed cache. When it prints nothing, tell the owner that `playbook-agents` is missing, and skip the rest. Run the next steps from the project's root.
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
