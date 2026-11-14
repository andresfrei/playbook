# Open questions

Each has a recommendation and says what it blocks. Answered questions move to [../decisions.md](../decisions.md). Numbers are kept from when each question was opened, so they are not consecutive.

## About the product

Each says which stage or step it blocks.

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q30 | Which version scheme does the plugin declare? Until then each commit is a version (TD3) | Decide before anyone other than the owner installs it | Sharing the product |
| Q24 | What is the product's final name? `playbook` is the working name (D39) | Decide before anyone other than the owner installs it | Sharing the product |

## About the owner's machine

These concern the owner's current installation and data, not what the product contains. They are kept apart from the product: the pages about the owner's installation live in the private `andresfrei/playbook-archive` (D147, which answers Q20).

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q16 | Engram's memory has one local copy. How is it protected? | Git Sync to a private repository | A risk to the owner's data |
| Q17 | Clean Engram's drifted project names with its repair commands? | Yes, rehearsed first on a copy of the data directory, with the owner approving the plan | Reliable recall per project |
