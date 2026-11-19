---
name: config
description: Set the model and the effort of the agents explore, write, and review, for this repository or for every project. Shows each agent's values and where they come from, then writes the person's choice.
disable-model-invocation: true
---

## When to use

- The person types `/playbook-agents:config` to see or change the model or the effort of `explore`, `write`, or `review`.

Do not use it for the model of the main session, which is Claude Code's `/model`.

## Rules

- Read and write only through the script. Never edit a settings file, `models.conf`, or an agent's file by hand.
- Offer only the models `haiku`, `sonnet`, `opus`, and `fable`, and the efforts `low`, `medium`, `high`, `xhigh`, and `max`. Claude Code takes only an alias when an agent is called.
- Ask only what the person's message does not already say.

## Steps

1. Run `sh "${CLAUDE_SKILL_DIR}/scripts/config.sh" show` and show its lines as a table: agent, model, effort, and where they come from. Show a line it prints about `CLAUDE_CODE_EFFORT_LEVEL`. When the script fails, show its message and stop.
2. Ask, with AskUserQuestion when available, the recommended option first with its reason:
   - Which agents to change. Stop when the person changes none.
   - For each, the model and the effort. Recommend the value shown, unless the person asked for something cheaper or stronger.
   - Where: "This repository" (`local`, kept out of git; it wins over the other) or "Every project" (`user`).
3. For each agent, run `sh "${CLAUDE_SKILL_DIR}/scripts/config.sh" set <local|user> <agent> <model> <effort>`. When it fails, show its message and stop.
4. Run `show` again and show the table.

## Output

- The table before and after, and each file written.
- That the values apply from the next call of each agent; no restart is needed.
- To go back to the plugin's value: remove the agent's line under `"playbook"` > `"models"` in the file named.
