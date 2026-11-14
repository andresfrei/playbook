# Open questions

Each has a recommendation and says what it blocks. Answered questions move to [../decisions.md](../decisions.md). Numbers are kept from when each question was opened, so they are not consecutive.

## About the product

Each says which stage or step it blocks.

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q30 | Which version scheme does the plugin declare? Until then each commit is a version (TD3) | Decide before anyone other than the owner installs it | Sharing the product |
| Q24 | What is the product's final name? `playbook` is the working name (D39) | Decide before anyone other than the owner installs it | Sharing the product |

## About the owner's machine

These concern the owner's current installation and data, not what the product contains. Under D29 they are kept apart from the product.

| # | Question | Recommendation | Blocks |
|---|----------|----------------|--------|
| Q20 | Where do the personal pages live (the inventory of installed skills, the audits, the memory statistics, this table)? | A separate private repository or a folder outside the product; move them before anyone else is given access | Sharing the repository |
| Q16 | Engram's memory has one local copy. How is it protected? | Git Sync to a private repository | A risk to the owner's data |
| Q17 | Clean Engram's drifted project names with its repair commands? | Yes, rehearsed first on a copy of the data directory, with the owner approving the plan | Reliable recall per project |
