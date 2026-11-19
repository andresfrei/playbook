# Open questions of the work version-check

| ID | Question | Recommendation | What it blocks |
|----|----------|----------------|----------------|
| version-check-Q2 | Who reads the notice: the person, through `systemMessage`, or the agent, as the format notice does today? | Both: `systemMessage` for the person and one line for the agent, after a trial shows that `systemMessage` reaches the person at the start of a session | The flows |
| version-check-Q3 | How often is the notice shown: every session while the versions differ, or once per new version? | Every session while they differ, in one line; it stops when the person updates | The flows |
| version-check-Q4 | Where does "what to run first" come from: a section of the release notes, or a line the plugin carries for each MAJOR version? | A line the plugin carries, such as "run /playbook-wiki:doctor in each project with a wiki", since the release notes are on GitHub, not on the machine | What it must do |
| version-check-Q5 | Which plugin carries the check: `playbook-wiki`, the only one every installation has, or each plugin for itself? | `playbook-wiki` alone, naming the three versions | The flows |
