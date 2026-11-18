# Definition of the work review-evidence

What this work must make true: the owner knows, with evidence, whether the validator of code does its job, and changes it only where the evidence shows a gap (review-evidence-1, review-evidence-2). The validator is the skill `review-change` and the agent `review` it runs on, in `plugins/playbook-agents`.

## The problem

The owner's concern is that the validator does its job. Two things are unknown:

1. Whether it finds defects when it runs. It has been checked on two seeded defects only.
2. Whether it runs when it should. R20 asks the agent to have `review` read a risky change before delivery, and nothing records how often it does.

Third parties agree that a reviewer improves through its context and through checking each finding, not through more rules ([research.md](research.md)). The validator already follows the three best-supported concepts, C1 to C3, so growing its text is not justified without a measurement.

## What exists today

Checked by reading the files on 2026-11-17:

- `plugins/playbook-agents/skills/review-change/SKILL.md`: one pass, read only, reports a defect only with a concrete failing case, reads the wiki pages that govern the paths changed.
- `plugins/playbook-agents/agents/review.md`: tools `Read, Grep, Glob, Bash`; model `opus` with effort `high` (`plugins/playbook-agents/models.conf`).
- Its cases in `plugins/playbook-agents/evals/`: two of triggering, `review-change-triggers` and `review-change-does-not-trigger`, and three of behaviour on small JavaScript repositories a fixture builds: `review-change-off-by-one` and `review-change-empty-input`, each with one seeded defect, and `review-change-clean-commit`, with none. None uses a diff of this repository.
- R20 in `plugins/playbook-agents/rules.md`: a change is risky when a mistake is hard to notice or undo; have `review` read it before delivery.

Two limits shape the wrapper, read in [Review locally with /code-review](https://code.claude.com/docs/en/code-review-local.md) on 2026-11-17: `/code-review` takes no instructions when it is called, since all the text after its effort level and flags is its target, and it follows the project's `CLAUDE.md`. The agent `review` has no `Skill` tool, so the wrapper runs in the session, and `/code-review` gives the separate context with its own subagent.

## Who has it

The owner, and anyone who installs `playbook-agents`: they rely on `review` to catch what the writing agent missed.

## What the work must do

- Measure the recall and the precision of `review` on real diffs of this repository with seeded defects, against Claude Code's `/code-review` on the same diffs (Decided: review-evidence-1).
- Measure how often `review` runs when R20 says it should (Decided: review-evidence-1), from the Claude Code transcripts of this repository's past sessions, read on the owner's machine with no paid run; only the counts reach the wiki (Decided: review-evidence-4).
- Propose a change to the validator only where the measurement shows a gap, citing the concept of [research.md](research.md) it comes from (Decided: review-evidence-2).
- Build `review-change` as a wrapper that ends up using Claude Code's `/code-review`: the wrapper chooses what to review and calls `/code-review` on it; a fixed rule in the project's `CLAUDE.md` makes `/code-review` read the wiki pages that govern the paths changed and report what contradicts a Decided statement (Decided: review-evidence-8). It is built when the measurement justifies it (Decided: review-evidence-2); the condition proposed is that `/code-review`, with the rule, finds at least what `review` finds (Proposed).
- A gap is shown when `review` misses a seeded defect that `/code-review` finds, or reports a finding that is not real, in at least 2 of 3 runs of the same diff; or when `review` did not run on a change R20 calls risky. This is fixed before measuring (Decided: review-evidence-3).

## What the work must not do

Decided (review-evidence-2):

- Copy anything from another tool or project: concepts are studied, not copied.
- Change the validator without evidence that justifies the change.

Decided (review-evidence-5):

- Run anything paid without the owner asking, or above the ceiling the owner approved for that run.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above |
| Who uses it | Covered: the owner, and the agent that delivers a change |
| Main flows | Covered: a change is delivered, `review` reads it or not, its findings reach the owner |
| What it must do | Covered: review-evidence-2, -3, -8 |
| What it must not do | Covered: review-evidence-2, -5 |
| Qualities | Covered: the measurement is repeatable, with recall and precision both counted ([research.md](research.md)) |
| Limits | Covered: each paid run when the owner asks, under a ceiling approved in stage 2, review-evidence-5 |
| Outside systems | Covered: Claude Code's `/code-review`, `claude plugin eval`, Anthropic's models |
| Volume | Covered: the transcripts of this repository's past sessions, review-evidence-4; the number of seeded diffs is set in stage 2 |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: the terms of [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md); recall and precision as in [research.md](research.md) |
