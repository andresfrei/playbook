# Skills

The skill or tool the agent uses for each job of this repository.

| Job | Technology | What the agent uses |
|-----|------------|---------------------|
| Write or change a skill or an agent | Claude Code plugins | Claude Code's `skill-creator`, the plugin documentation read verbatim from `https://code.claude.com/docs/llms.txt`, and `claude plugin validate` |
| Write the hooks and the check | Plain shell | No skill; `shellcheck` |
| Evaluate a new Claude Code release | Claude Code | The project skill `evaluate-cli-releases` |
| Define, close, and release a work | The playbook | Its own skills `define`, `close`, `release` |
