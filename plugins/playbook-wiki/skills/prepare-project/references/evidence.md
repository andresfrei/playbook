# Evidence at the close of a work

Turn repeated findings of `review` into a rule one level up (repeated-corrections-5, -12, -13), and send a rule that keeps resisting into the skill or agent it belongs to (rule-promotion-3 to -6).

## When

At the close of a work, when `docs/wiki/evidence.md` exists. Skip silently otherwise.

## Steps

1. Locate `evidence.sh` as "Locate a script" in the client's working-agent instructions says. If the agents plugin is unavailable, tell the owner and skip the rest of this file. Run subsequent commands from the project root with the quoted absolute script path.
2. Run `sh <script> count docs/wiki`. Each line "ready to consolidate: <kind> (level N): R distinct reviews, last DATE" is one group: kind K at level k. Each line "revise graduated step: <kind> → <path>: ..." is for step 8. With no "ready" line, go to step 7.
3. For each group, write one rule of level k+1 that covers every level-k Evidence row of K:
   - concrete, with an example inside;
   - says when it applies: which files or which kind of change;
   - cites its source as "<R> reviews, <first date> to <last date>".
4. Propose it to the owner, one group at a time, with the rows it replaces. When a delegation in force covers the kind `consolidate`, do not ask: do step 5 and say so in one line.
5. On a yes, or under a delegation: in Kinds, set the Level of K to k+1 and its Rule, Applies when, and Source. Delete the level-k Evidence rows of K; git keeps them. Run `sh <script> check docs/wiki`.
6. Record a decision of kind `consolidate` in the work's `decisions.md`: as recommended, changed, or rejected, or delegated; its shared page is "none". A rejected proposal keeps its rows; do not propose the same group again in this work.
7. For a kind with Scope `general` at level 2 or up, consolidated or not, leave out one whose Source is `evidence-rules.md` or starts with `graduated to`, and one the owner already declined to send up. When `plugins/playbook-agents/evidence-rules.md` exists in this repository, propose adding the rule there; otherwise tell the owner that it can go up to the playbook (repeated-corrections-20), as a proposal the owner carries. Record the answer as a decision of kind other, so a declined proposal is not made again.

8. Graduation. Skip it unless `plugins/playbook-agents/evidence-rules.md` exists in this repository. Never delegate it (rule-promotion-4), even when a delegation covers `consolidate`.
   - For each kind of that file at level 3 or more, leave out one whose Source in `docs/wiki/evidence.md` says `graduated to` and one the owner declined in a decision of this or an earlier work. Propose, one kind at a time:
     - the destination: the one skill or agent whose job the rule's action belongs to. `rules.md` only by replacing text, since it loads 620 of 620 words (L4);
     - the exact step text;
     - one case of behaviour for that skill's or agent's evals.
   - For each "revise graduated step: <kind> → <path>" line of step 2, propose revising the step at <path> with the findings of the kind, in the same three parts.
   - On a yes, write the text into the destination within its limits: a skill body stays at 700 words or less (style guide of `write-skill`); text that does not fit goes into a reference file that a step reads. A revision replaces the step. In both cases, delete the kind's Evidence rows in `docs/wiki/evidence.md`, as step 5 does, so only later findings count toward a revision; git keeps them. Add the case under that plugin's `evals/`; do not run it unless the owner asks. For a new graduation, also delete the kind's row from `evidence-rules.md` and set its Source in `docs/wiki/evidence.md` to `graduated to <path>`, adding the kind's row when the page lacks it. Run `sh <script> check docs/wiki`.
   - Record a decision of kind `other`: as recommended, changed, or rejected; its shared page is "none". A rejected kind is not proposed again.

## Rules

- Never consolidate across levels or kinds.
- Never weaken a rule into something vague.
