# Questions of the work skill-adherence

| ID | Question | Recommendation | Blocks |
|----|----------|----------------|--------|
| skill-adherence-Q7 | `keep-minimal-triggers` loads the skill in 1 of 3 runs, also now that its request needs the repository: the agent runs `git show` and reviews the commit itself, well, though the description names "unnecessary complexity" ([measurements.md](measurements.md)). What makes the agent load a skill for a review it can do itself? | A later work that compares, on every skill, how often a review is done without its skill, before changing a description again | none |
| skill-adherence-Q8 | `prepare-project-new-project-stage-one` ends with one question in 2 of 3 runs with the plugin and 0 of 3 without; the failing run asks "Does the clinic have several dentists, and are all appointments the same length?" ([measurements.md](measurements.md)). Is 2 of 3 enough, or does the skill need more? | A later work, after more runs show whether 2 of 3 holds | none |
