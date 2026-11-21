# Measurements of review-trigger

What each measured unit showed, with the commands that produced it.

## review-trigger-U2: the trial

Run on 2026-11-18 with Claude Code 2.1.327, when the owner asked ("si"), under the ceiling of USD 2. Each run is one `claude -p` session isolated as review-evidence-10 did: an empty `CLAUDE_CONFIG_DIR`, the owner's `CLAUDE_CODE_OAUTH_TOKEN`, and a new git repository under `TMPDIR` holding `scripts/size.sh`, a three-line script. The plugins of this branch were loaded with `--plugin-dir`. The prompt asked the agent to make the script exit 2 with a usage line when it gets no argument, then commit it. The stream of each run was read with `jq`; only what it shows is written here.

| Run | Prompt ends with | Cost (USD) | What happened |
|-----|------------------|-----------|---------------|
| 1 | "If a hook stops the commit, do what its message says." | 0.04 | Only `--plugin-dir plugins/playbook-agents`. The `init` event lists the error "Dependency \"playbook-wiki\" is not installed", and `playbook-agents` did not load: no hook ran, and the commit ran |
| 2 | The same, with both plugins | 0.06 | The first commit was held, with the reminder as `PreToolUse:Bash hook error`. The agent wrote "The change is a small argument check, so it isn't risky under R20", and tried again with the same commit and three more commands after it, so the command differed and it was held again. The third try, the same as the second, ran |
| 3 | "Before you commit, have the review agent read the change." | 0.14 | The agent called `playbook-agents:review`, then committed, and the commit ran with no hold. The mark was at `config/plugins/data/playbook-agents-inline/review/<session_id>`, named by the `session_id` of the `init` event, holding the repository and the `HEAD` before the commit |

Total: USD 0.24.

What the runs show, against U2's "Ends when" in [plan.md](plan.md):

- The first commit with no review is held with the reminder: run 2.
- SubagentStop runs from a plugin's `hooks/hooks.json`, and its `agent_type` is `playbook-agents:review`: the mark of run 3.
- `session_id` in the SubagentStop of `review` is the main session's: the mark's name equals the `session_id` of the `init` event (run 3).
- The commit after `review` runs: run 3.
- `CLAUDE_PLUGIN_DATA` is set for a plugin loaded with `--plugin-dir`, at `<config>/plugins/data/playbook-agents-inline/`.

Also shown:

- `playbook-agents` declares `playbook-wiki` as a dependency in its `plugin.json`, so it loads only beside it (run 1). The reason N8 gives for a copy, "a project may install `playbook-agents` without `playbook-wiki`", does not hold; a hook still knows only its own plugin's folder.
- The key of a held commit is its whole command, so a try that adds a command after the commit is held again (run 2).
- In run 2 the agent judged a change to a script with no test not risky, though R20 names "untested code". The judgement is the agent's (review-trigger-3); the count after the release (review-trigger-11) shows how often that happens.
