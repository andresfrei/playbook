# Questions of the work review-evidence

| ID | Question | Recommendation | Blocks |
|----|----------|----------------|--------|
| review-evidence-Q4 | `review` did not run before 27 of the 37 risky commits of this repository ([measurements.md](measurements.md), U1): R20 is a written rule, which the agent may decide does not apply. How is the review made to run when R20 says it should? | A later work that runs the review before a risky commit through a hook, as Anthropic advises for what must happen every time ([research.md](research.md), C4), and counts again as U1 did | none |
| review-evidence-Q5 | In the diff `folder`, `review-change` put a real finding, a shared page of the wiki left without the new rule, under "Not checked" in two of three runs, where `/code-review` reported it in six of six ([measurements.md](measurements.md), U4). Does `review-change` need to report a page left on an old definition as a finding? | No change for now: one diff, and `review-change` already reports a path left on the old definition; watch for it in a later measurement | none |
