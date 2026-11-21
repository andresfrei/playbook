# Playbook for Codex CLI

From the repository root, check the installer requirements with `python3 codex/install.py --check`. It reports the Python, Git, and Codex CLI versions, checks for the Unix packaging tools, and verifies the Codex plugin commands using a temporary profile. Python 3.11 or newer is required. Codex compatibility depends on the available commands. See the [OpenAI plugin guide](https://developers.openai.com/plugins/build/plugins).

To run the check and install Playbook, run

```sh
python3 codex/install.py
```

Choose **wiki only** or **wiki and agents**. The installer registers the local marketplace in your Codex profile. Rerun the same command after updating the checkout or to add the agents later. It reports the step that failed if installation stops.

Open Codex in the target repository and review the plugin hooks with `/hooks`. Trust the definitions to enable them, then start a fresh session to load the contract. The commit check applies to changes under `docs/wiki/` in repositories with a current wiki format marker.

Before a merge, the plugin checks for decisions added on both branches and shared wiki pages touched by both. When the comparison needs review, Codex stops the command and reports the items to discuss. After reviewing them, the owner can complete the merge in their terminal. Other merges proceed normally.

At session start, a wiki with a missing or outdated format marker also produces a notice. Select the plugin's `migrate` skill in `/skills` to bring the wiki to the current format (6). Selecting it is the owner's acceptance: it migrates without proposing first, returns what changed and every estimated value, and marks the wiki only after validation succeeds. Git is the undo. Its project instruction file is `AGENTS.md`.

In Claude Code, `migrate` and the close of a work run in the agent `wiki-writer`. Codex cannot run a skill in a forked agent and the plugin ships no agent, so there the session itself does the work: it follows `wiki-writer.md` at the plugin root, which holds the agent's steps, and runs `check-wiki.sh` until it passes. No personal profile is installed for it.

Ask Codex to start a project, prepare an existing repository, or continue an open work. It can select `playbook-wiki:prepare-project` from the request. Subagents receive the wiki contract when they start. It walks through the wiki, technology, skills, design system, plan, and execution. The owner closes each stage. The bundled `playbook-wiki:write-docs` skill records definitions and updates documentation during that process and can also be selected on its own.

To have Codex perform the installation, copy the [Codex CLI installation prompt](../README.md#codex-cli-prompt).

## Working agents

During a work, the main session records review findings on the work branch. At close, `prepare-project` uses the enabled `playbook-agents` plugin to count evidence and record recurring tasks. After the owner approves a task agent, it gets a project-local profile under `.codex/agents/`.

The full installation places three personal profiles in the Codex agents directory (normally `~/.codex/agents/`). It preserves existing profiles and reports conflicts. This also applies to profiles from an earlier manual installation: compare the settings if you want the new defaults.

| Agent | Default model | Reasoning effort |
|-------|---------------|------------------|
| explore | gpt-6.2-sol | low |
| write | gpt-6.2-sol | medium |
| review | gpt-6.2-astra | high |

The review reminder holds the first code commit once per repository HEAD and session. A completed review or a retry on that HEAD permits the commit. A wiki-only change is checked by the wiki plugin. Choose which hooks to trust in Codex. Your MCP servers and terminal preferences stay under your control.
