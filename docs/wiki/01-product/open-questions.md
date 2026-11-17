# Open questions

Each has a recommendation and says what it blocks. Answered questions move to [../decisions.md](../decisions.md). Numbers are kept from when each question was opened, so they are not consecutive.

## About the product

Phase 4 opened Q53 to Q60 on 2026-11-16, and D171 to D178 answered them: [phase-4.md](phase-4.md). One question is open: the release after version 2 (D198). Q62, whether the product adopts the way phase 4 is worked (D208), was answered by phase-4-1 in [../works/phase-4/decisions.md](../works/phase-4/decisions.md).

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q61 | What does Anthropic's plugin directory ask of the product, and which of the three plugins are submitted? What is known is in [../05-plan/plan-phase-4.md](../05-plan/plan-phase-4.md), under "After the plan". | Read the directory's pre-submission checklist and its policy when the next release is prepared, and decide then which plugins to submit. | The submission. Nothing in phase 4 |

## About the owner's machine

These concern the owner's current installation and data, not what the product contains. They are kept apart from the product: the pages about the owner's installation live in the private `andresfrei/playbook-archive` (D147, which answers Q20).

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q16 | Engram's memory has one local copy. How is it protected? | Git Sync to a private repository | A risk to the owner's data |
| Q17 | Clean Engram's drifted project names with its repair commands? | Yes, rehearsed first on a copy of the data directory, with the owner approving the plan | Reliable recall per project |
