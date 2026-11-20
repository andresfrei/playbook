# Open questions of the work parallel-units

| ID | Question | Recommendation | What it blocks |
|----|----------|----------------|----------------|
| parallel-units-Q1 | Where are the batches decided? | In stage 5, as a table of batches in `plan.md`: batch, units, the paths each unit may change, and what it waits for. The owner accepts it with the plan. It replaces the yes or no question of step 5 | Main flows |
| parallel-units-Q2 | How do two agents of a batch avoid each other? | Each `write` works in its own worktree, on its own branch, so a shared file such as a test script is not a reason to wait. Each one gets the exact paths it may change (R21) | What it must do |
| parallel-units-Q3 | How does a unit of a batch reach the work's branch? | The main agent merges it when its checks pass, after `review` when the unit is risky (R20). On a conflict, the main agent resolves it and runs the checks of both units again | What it must do |
| parallel-units-Q4 | When does the next batch start? | When every unit it waits for is Done. A unit Built and waiting for the owner's judgement holds only the units that wait for it | What it must do |
| parallel-units-Q5 | How many agents run at once? | At most three per batch; a larger group splits into two batches. Each agent costs its own tokens | Limits |
