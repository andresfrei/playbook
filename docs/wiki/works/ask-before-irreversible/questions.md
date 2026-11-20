# Open questions of the work ask-before-irreversible

| ID | Question | Recommendation | What it blocks |
|----|----------|----------------|----------------|
| ask-before-irreversible-Q5 | How does the person start the proposal of a repository's rules? | A command only the person starts, such as `/playbook-agents:protect`, run inside the repository: protecting a repository is a job of its own (R17), and a command only the person starts does not count against L4 (seed-evidence-2) | Who uses it; main flows |
| ask-before-irreversible-Q6 | What does the proposal contain? | Read rules `deny` for the secret files found in the repository (such as `.env*`, keys, credentials), `ask` rules for deleting files and resetting history (`rm -r`, `git reset --hard`, `git branch -D`, `git clean`), and turning on the sandbox; each item shown and chosen by the person before anything is written | What it must do |
| ask-before-irreversible-Q7 | Where are the chosen rules written? | In the repository's `.claude/settings.json`, so everyone who works on it gets them, or in `.claude/settings.local.json` when the person prefers to keep them out of git; asked once per run, adding to what the file holds and changing nothing else | Main flows; limits |
