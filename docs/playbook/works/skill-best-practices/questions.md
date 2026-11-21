# Questions of the work skill-best-practices

| ID | Question | Recommendation | Blocks |
|----|----------|----------------|--------|
| skill-best-practices-Q1 | `review-change` did not load in two of its three cases ("Review the last commit before I open the pull request"), `keep-minimal` in `keep-minimal-add-feature`, and `prepare-project` in `prepare-project-no-code-before-stage-six`: the agent did the task without the skill. How should their descriptions change? | A work on triggering, with the cases of triggering run three times per arm | none |
| skill-best-practices-Q2 | With the skill loaded, `review-change` ends its report with a question, which its Output forbids (`review-change-off-by-one`). What fixes it? | A gotcha in `review-change`, measured in the same work as Q1 | none |
| skill-best-practices-Q3 | With the skill loaded, `prepare-project` asks two questions in its first answer to a new project (`prepare-project-new-project-stage-one`). Is it the skill, or the roles check of the contract? | Read the trace of a new run before changing either | none |
| skill-best-practices-Q4 | With the skill loaded, `avoid-generic-design` built a page with three equal columns, and scored lower than without it (`avoid-generic-design-build-page`). What does its produce step miss? | A gotcha in `avoid-generic-design`, from that run | none |
| skill-best-practices-Q5 | `wiki-format.sh mark` keeps a copy of the marker with `mktemp`; where the temporary folder cannot be written, as in `claude plugin eval`, it fails with exit 4. Should it keep the copy elsewhere? | Keep the copy beside the marker in the wiki's folder, which `mark` must write anyway | none |
