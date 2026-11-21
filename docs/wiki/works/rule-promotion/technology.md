# Technology of the work rule-promotion

How graduation (definition.md) is built. Decided (rule-promotion-8).

- **N1. No new dependency.** It uses what consolidation already uses: `plugins/playbook-agents/evidence.sh` in plain sh and awk (TD2), and the close step of `prepare-project`.
- **N2. Where it runs.** A new step at the end of `plugins/playbook-wiki/skills/prepare-project/references/evidence.md`. It applies only where `plugins/playbook-agents/evidence-rules.md` exists, which is the playbook's own repository (rule-promotion-7). For each kind there at level 3 or more, the agent proposes three things, one kind at a time: the destination file, the exact step text, and the case of behaviour. It leaves out a kind already graduated and one the owner declined in a decision.
- **N3. On a yes.** The step does four things:
  - writes the text into the destination;
  - adds the case under that plugin's `evals/`;
  - deletes the kind's row from `evidence-rules.md`;
  - sets the kind's Source in the project's `docs/wiki/evidence.md` to `graduated to <path>`.

  It records a decision of kind `other`: as recommended, changed, or rejected.
- **N4. Counting after graduation.** `evidence.sh count` reads a Source that starts with `graduated to`. For such a kind, the line becomes `revise graduated step: <kind> → <path>: R distinct reviews, last DATE` in place of "ready to consolidate", and the close step proposes revising that step (rule-promotion-5). Below the threshold it stays "not ready". `evidence.sh check` accepts the value.
- **N5. Limits.** A destination keeps its own limits: a skill's body stays at 700 words or less, by the style guide. When the text does not fit, it goes into one of the skill's reference files that a step reads. `rules.md` changes only by replacing text (L4, 620 of 620 words).
- **N6. What the agents see.** The `SubagentStart` index of `write` and `review` reads `evidence-rules.md`, so a graduated rule leaves that index. It now lives in its destination.
