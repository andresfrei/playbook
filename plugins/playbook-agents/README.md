# playbook-agents

A way of working for building software with an AI coding agent: working rules the agent follows in every project, three agents to delegate to, and four skills. It is the agent system of [playbook](https://github.com/andresfrei/playbook)'s author, shared for whoever wants it.

It needs `playbook-wiki`, the core of playbook, which keeps a project's definitions and decisions in a wiki inside the repository. Installing this plugin from its marketplace installs `playbook-wiki` with it; if `claude plugin list` does not show `playbook-wiki`, install it too.

## What it holds

| Part | What it does |
|------|--------------|
| [rules.md](rules.md) | The working rules: how the agent talks to you, decides, builds, delegates, and delivers |
| `explore` | An agent that maps where something lives across many files, without changing them |
| `write` | An agent that builds one bounded unit of work with its tests |
| `review` | An agent that reads a risky change in a separate context and returns findings |
| `keep-minimal` | Keeps an implementation the simplest one that solves the current problem |
| `review-change` | Reviews a change, a diff, or a commit for defects before it is merged |
| `write-skill` | Writes or audits a skill in a fixed format and within size limits |
| `avoid-generic-design` | Keeps out the generic look AI tools give a page or an interface by default |

The model and effort of each agent are set in [models.conf](models.conf).

## Hooks

One hook, when a session starts. It prints [rules.md](rules.md) with `cat`, and then, when you set the option `language`, one line asking the agent to talk to you in that language. It changes no file and no setting, connects to no network, and nothing leaves your machine. The rules are text the agent reads at the start of each session, in every project where the plugin is on.

## Examples

```text
Review this diff before I merge it.
```

```text
Write a skill that prepares the release notes of this repository.
```

```text
Review the landing page in src/pages/index.tsx for a generic AI look.
```

## Install

From this repository's marketplace, in Claude Code:

```sh
claude plugin marketplace add andresfrei/playbook
claude plugin install playbook-agents@playbook --scope user
```

The full guide, with the start command `/playbook:init` and the tools some rules name, is in the [repository's README](https://github.com/andresfrei/playbook#install).

## Support

Report a problem or propose a change in the [repository's issues](https://github.com/andresfrei/playbook/issues). Report a vulnerability as [SECURITY.md](https://github.com/andresfrei/playbook/blob/main/SECURITY.md) says.

## Licence

MIT, as [LICENSE](https://github.com/andresfrei/playbook/blob/main/LICENSE) says.
