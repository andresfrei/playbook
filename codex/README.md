# Playbook for Codex CLI

Use a local checkout with Codex CLI, Git, Python 3.11 or newer, and a Unix shell toolchain. The installer was tested on Linux with Codex CLI 0.170.0. From the repository root, run:

```sh
python3 codex/install.py
```

Choose **wiki only** or **wiki and agents**. The installer registers the local marketplace in your Codex profile. Rerun the same command after updating the checkout or to add the agents later. It reports the step that failed if installation stops.

Open Codex in the target repository and review the plugin hooks with `/hooks`. Trust the definitions to enable them, then start a fresh session to load the contract. The commit check applies to changes under `docs/wiki/` in repositories with a current wiki format marker.

Before a merge, the plugin checks for decisions added on both branches and shared wiki pages touched by both. When the comparison needs review, Codex stops the command and reports the items to discuss. After reviewing them, the owner can complete the merge in their terminal. Other merges proceed normally.

At session start, a wiki with a missing or outdated format marker also produces a notice. Select the plugin's `doctor` skill in `/skills` to review the repairs. It proposes changes for the owner to approve and marks the wiki only after validation succeeds. Its project instruction file is `AGENTS.md`.

Ask Codex to start a project, prepare an existing repository, or continue an open work. It can select `playbook-wiki:prepare-project` from the request. Subagents receive the wiki contract when they start. It walks through the wiki, technology, skills, design system, plan, and execution. The owner closes each stage. The bundled `playbook-wiki:write-docs` skill records definitions and updates documentation during that process and can also be selected on its own.

To have Codex perform the installation, copy the [Codex CLI installation prompt](../README.md#codex-cli-prompt).

## Working agents

The full installation places three personal profiles in the Codex agents directory (normally `~/.codex/agents/`). It preserves existing profiles and reports conflicts. This also applies to profiles from an earlier manual installation: compare the settings if you want the new defaults.

| Agent | Default model | Reasoning effort |
|-------|---------------|------------------|
| explore | gpt-6.2-sol | low |
| write | gpt-6.2-sol | medium |
| review | gpt-6.2-astra | high |

The review reminder holds the first code commit once per repository HEAD and session. A completed review or a retry on that HEAD permits the commit. A wiki-only change is checked by the wiki plugin. Choose which hooks to trust in Codex. Your MCP servers and terminal preferences stay under your control.
