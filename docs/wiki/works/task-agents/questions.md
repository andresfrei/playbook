# Open questions of the work task-agents

| ID | Question | Recommendation | What it blocks |
|----|----------|----------------|----------------|
| task-agents-Q1 | How is a repeated task noticed? | As findings are: a page `docs/wiki/tasks.md`, one row each time the agent ends a task it has done before, with the task's name, the date, the work, and its steps in one line. The agent writes the row when it ends the task; nothing reads transcripts | Main flows |
| task-agents-Q2 | When does a task count as repeated? | When it appears in 3 distinct works, the same threshold as evidence; three times in one work may be a single burst | What it must do |
| task-agents-Q3 | How is the model chosen by the task's weight? | Three weights: mechanical steps with fixed commands go to `haiku` with low effort; steps that write text or judge a small change go to `sonnet` with medium effort; a task that decides, designs, or touches what R14 and R20 guard stays in the main session. The proposal names the steps that stay there, such as the release notes | What it must do |
| task-agents-Q4 | Where does the dedicated agent live? | In the project, in `.claude/agents/`, so it costs nothing in L4 of `playbook-agents`. When it serves every project, it is proposed to the playbook, as a general rule is | Limits |
