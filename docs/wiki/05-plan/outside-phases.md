# Work outside the phases

Work done in this repository outside any phase, with what was run for each. The plans of the three phases are in [plan.md](plan.md), [plan-phase-2.md](plan-phase-2.md), and [plan-phase-3.md](plan-phase-3.md).

After phase 2, outside any phase:

- **Delivery of a unit, per project (D99, D100).** `prepare-project` asks in stage 5 how a unit is delivered (its branch, pull request or local merge, parallel units) and stage 6 follows the answer. Done and accepted (D100): commit `0dfda72` on `main`, merged from branch `feat/prepare-project-delivery`; pushed to `origin` (D103). Run on 2026-11-13: `bash scripts/verify.sh` exited 0 with 776 words at session start; `bash scripts/verify_test.sh` printed "all cases passed"; the body of the skill has 696 words (limit 700). Not run: the paid evaluation, and a stage 5 in a real project.
- **Documents of a project already started (D101, D102).** Stage 1 of `prepare-project` reads the documents the repository already holds, takes what they say as Proposed, and writes an ambiguous point as an open question. Done and accepted (D102): commit `d68d11f` on `main`, merged from branch `feat/prepare-project-existing-docs`; pushed to `origin` (D103). Run on 2026-11-13: `bash scripts/verify.sh` exited 0 with 776 words at session start; `bash scripts/verify_test.sh` printed "all cases passed". Not run: the paid evaluation, and a stage 1 in a real project already started.
