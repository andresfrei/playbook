# Open questions of the work ask-before-irreversible

| ID | Question | Recommendation | What it blocks |
|----|----------|----------------|----------------|
| ask-before-irreversible-Q1 | Which actions does the hook stop? | The delivery actions of R14 only: `git push` in every form (with `-C <dir>`, tags, `--delete`), `gh pr create`, `gh pr merge`, and `gh release` create, edit, and delete. Other actions that cannot be undone, such as deleting files or reading secrets, wait for a later work | What it must do; what waits |
| ask-before-irreversible-Q2 | What does the person see when the hook stops an action? | Claude Code's own permission prompt, with the reason "R14: push, pull requests, and merges are the owner's decisions", in every mode the person uses; where a mode shows no prompt, the action is refused with that reason, so the agent asks in the conversation | Main flows; qualities |
| ask-before-irreversible-Q3 | Does a "yes" given in the conversation skip the prompt? | No: the prompt is shown every time. The hook cannot read the conversation, and one click is cheaper than a push the person did not mean | Business rules |
| ask-before-irreversible-Q4 | Does it also stop the actions of subagents? | Yes, with the same prompt: a subagent's tool calls run the same hooks, and R14 has no exception for them | What it must do |
