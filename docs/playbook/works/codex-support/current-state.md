# Codex adaptation before the installer

The existing adaptation packages the wiki and working agents from their Claude sources. The owner requirements are in [decisions.md](decisions.md). The observations below describe the starting point for the work.

| Area | Observed behaviour | Evidence |
|------|--------------------|----------|
| Installation | Packaging creates a local marketplace. Registering it, installing plugins and copying personal agent profiles are separate steps. | [Package script](../../../../codex/package.sh) and [local installation instructions](../../../../codex/README.md) |
| Wiki | The plugin loads the contract at session and subagent start, checks wiki commits and stops merges requiring a decision comparison. The owner completes a reviewed merge in the terminal. | [Wiki hooks](../../../../codex/playbook-wiki/hooks.json) and [merge adapter](../../../../codex/playbook-wiki/merge-review.py) |
| Agents | The package includes working rules, four skills and the commit review reminder. The three personal roles inherit the session model. | [Agent hooks](../../../../codex/playbook-agents/hooks.json) and [role generator](../../../../codex/playbook-agents/package-roles.py) |
| Local setup | Engram, CodeGraph and Context7 were registered in the owner's Codex profile. The owner also requested a compact transcript and a status line showing branch, context remaining and plan limits. | Local setup performed on 2026-11-18. The installer preserves these personal settings under [codex-support-5](decisions.md). |

## Public README task

Decided in [codex-support-7](decisions.md). The [public README](../../../../README.md) introduces Playbook as a Claude Code product and combines first-time installation, architecture diagrams, updates, removal and contributor checks. Proposed outcome: a short introduction and a clear installation path for each client. Move or link detailed material to the relevant guides. Verify the links and the documented commands against the delivered versions before closing the work.

## Not verified

A fresh user completing installation from a single command, rerunning it on an existing setup, and exercising a real delegated review through the next commit remain to be demonstrated.
