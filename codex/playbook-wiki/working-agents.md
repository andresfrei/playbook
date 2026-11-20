# Working agents in Codex CLI

## Locate the agents plugin

From the target project, run `codex plugin list --marketplace playbook --json`. In `installed`, find `playbook-agents@playbook` with `enabled` set to true. If absent or disabled, skip the steps that require the plugin. If the command fails, report the error.

From the installed `prepare-project` skill directory, the agents plugin root is `../../../../playbook-agents/<version>/`, using the version of that entry. Resolve the requested file under that root. If it is missing, report the incomplete installation and stop that procedure. Quote absolute paths when running scripts.

## Review findings

After a work's review returns findings, the main session uses `record-findings.md` at the agents plugin root. Supply the findings, their stable review identifier and date, and the absolute root of the work branch. On a retry, skip occurrences already recorded for that review. Keep the review agent read-only.

## Recurring tasks

Use the installer's `gpt-6.2-sol` model with low reasoning effort for mechanical commands and medium effort for writing or judging small changes. Show the proposed model, effort and file path to the owner. For an approved task, create `.codex/agents/<task>.toml` in the project. If the name or path is already in use, resolve the collision with the owner before writing the file or marking the task as assigned.

Set `name`, a one-line `description` saying when to use the agent, `model`, `model_reasoning_effort`, and `developer_instructions` containing the delegated steps and stopping point. [Codex subagents](https://developers.openai.com/codex/subagents)
