# Working agents in Claude Code

## Locate a script

From the `prepare-project` skill directory, look for the requested script under `../../../playbook-agents/`. For a versioned plugin cache, take the highest installed version under `../../../../playbook-agents/` that contains the script. Use its absolute path.

## Review findings

The review agent delegates classification to `playbook-agents:classify`. Keep one copy of the evidence on the work branch.

## Recurring tasks

Use `haiku` with low effort for mechanical commands and `sonnet` with medium effort for writing or judging small changes. For an approved task, create `.claude/agents/<task>.md`. Its front matter holds `name`, a one-line `description` saying when to use it, `tools`, `model`, and `effort`. Put the instructions in the Markdown body.
