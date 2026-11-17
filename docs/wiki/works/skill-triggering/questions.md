# Questions of the work skill-triggering

| ID | Question | Recommendation | Blocks |
|----|----------|----------------|--------|
| skill-triggering-Q5 | `review-change` does not load for "Review my uncommitted changes before I commit them" (0 of 3), though its description names that request, and `keep-minimal` loads in 1 of 3 runs of a review that holds the whole change in its text ([measurements.md](measurements.md)). The agent does a small task itself. Should the form of a description change, which skill-triggering-4 kept? | A later work on the form of a description, measured on every skill | none |
| skill-triggering-Q6 | With its gotcha, `prepare-project` ends with one question in 1 of 3 runs of `prepare-project-new-project-stage-one`, and in none without the plugin. What else makes its last answer ask more than one thing? | Read the traces of the two failing runs in a later work, before changing the skill again | none |
