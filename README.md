[![Playbook](docs/assets/playbook-banner.png)](https://playbook.neuralmind.lat/)

# Playbook

[![Latest release](https://img.shields.io/github/v/release/andresfrei/playbook?label=release&color=ff5a1f)](https://github.com/andresfrei/playbook/releases)
[![License: MIT](https://img.shields.io/github/license/andresfrei/playbook?color=ffb020)](LICENSE)

**[playbook.neuralmind.lat](https://playbook.neuralmind.lat/)** · Claude Code · by [NeuralMind](https://neuralmind.lat/)

## For AI agents

- Playbook is a Claude Code plugin: it defines each change with the owner before code, records decisions in the owner's words, and proposes rules from repeated mistakes.
- Install: `/plugin marketplace add andresfrei/playbook`, then `/plugin install playbook@playbook`.
- Commands: `/playbook:define`, `/playbook:close`, `/playbook:audit`, `/playbook:audit-learning`, `/playbook:release`, `/playbook:permissions`.
- It writes `docs/playbook/` in the project, and lines it proposes for `CLAUDE.md`, `.claude/rules/`, or a skill, which the owner accepts or not.
- The source is `plugins/playbook/`. Each piece has a page in [docs/reference/README.md](docs/reference/README.md).

## What it is

Playbook is a free Claude Code plugin that helps you build fast without losing track. You decide what the software should do; Claude writes it down in your repository with your words, builds from it, and turns its repeated mistakes into project rules.

It adds only what Claude Code does not already do. Writing stays in your session, or goes to the agent [builder](docs/reference/builder.md) when you choose it, memory is Claude Code's auto memory, and one big mechanical change across many files is `/batch`.

## How a change goes

1. **Define.** [`/playbook:define`](docs/reference/define.md) names the type of change and runs only the steps it needs:

   | Type of change | Steps |
   |----------------|-------|
   | Small change | None: Claude just does it |
   | Feature on your current technology | Define |
   | Feature that adds or replaces a technology | Define, Technology, Skills |
   | New project | Define, Technology, Skills, and Design when it has an interface |

   It asks one question at a time, cites what you already decided instead of asking again, checks each technology in its current documentation, and writes a spec with how to check it. You accept the spec once.
2. **Build.** In your session, on the model you choose with `/model`; or, with the line `Build mode: builder`, the agent [builder](docs/reference/builder.md) on Sonnet builds each unit from a brief and your session verifies it. See [build mode](docs/reference/build-mode.md).
3. **Close.** [`/playbook:close`](docs/reference/close.md) runs the spec's check, has the read-only [reviewer](docs/reference/reviewer.md) read a risky change, and proposes one line for each mistake that happened twice, or each answer you gave twice: for `CLAUDE.md`, `.claude/rules/`, or a skill. You accept each line or not.
4. **Audit**, when you adopt a project, before a release, or when `close` suggests it. [`/playbook:audit`](docs/reference/audit.md) reads the wiki against the code, checks what loads at startup and the repository's tools, and shows each finding for you to resolve. [`/playbook:audit-learning`](docs/reference/audit-learning.md) finds what repeats across two works and proposes a delegation, a rule, a skill, or an agent.
5. **Release.** [`/playbook:release`](docs/reference/release.md) sets the version and drafts the notes. Pushing, opening or merging a pull request, and publishing a release always ask you first ([ask](docs/reference/ask.md)).

Everything lives in `docs/playbook/` ([wiki](docs/reference/wiki.md)): the product, each work's spec, and its decisions with who decided and their words. Its `README.md` loads at the start of every session ([session-start](docs/reference/session-start.md)).

## Install

In a Claude Code session:

```text
/plugin marketplace add andresfrei/playbook
/plugin install playbook@playbook
```

The installer asks where to turn it on:

| Scope | Who gets it | Where it is recorded |
|-------|-------------|----------------------|
| User | You, in every project on this machine | `~/.claude/settings.json` |
| Project | Everyone who works in this repository | `.claude/settings.json`, which you commit; each collaborator installs it once with `--scope project` |
| Local | You, in this repository only | `.claude/settings.local.json` |

From your shell, `claude plugin install playbook@playbook` installs it for you in every project; add `--scope project` or `--scope local` to choose another.

The `/playbook:permissions` wizard needs `jq` on your PATH.

Then start a new session in your project and run [`/playbook:audit`](docs/reference/audit.md). On its first run it adopts the project: it reads the documentation and rules the project already has, proposes how to order them, builds the wiki in `docs/playbook/`, cleans `CLAUDE.md`, and checks the repository's tools, asking you each choice. It starts from a clean git tree, so all it changes is one diff. Until a project is adopted, each session in its git repository recommends it ([adopt](docs/reference/adopt.md)).

## Updates

To get new versions, turn on auto-update: run `/plugin`, open the **Marketplaces** tab, select `playbook`, and turn auto-update on. Claude Code then installs each new version in the background and shows `Plugin updated: playbook · Run /reload-plugins to apply`; without the reload, the new version loads on the next launch. It is off by default for marketplaces other than Anthropic's, and a plugin cannot turn it on for you.

## Reference

- [Reference index](docs/reference/README.md): one page per skill, agent, hook, and concept.
- [Permissions](docs/reference/permissions.md): `/playbook:permissions`, a wizard for attribution and allow, ask, and deny rules.
- [Upgrade from version 4](docs/reference/upgrade-from-4.md): moving from version 4 to 5.
- To make searches cheaper, copy [`plugins/playbook/extras/Explore.md`](plugins/playbook/extras/Explore.md) to `~/.claude/agents/`; see [sessions](docs/reference/sessions.md).

## Documentation

- [What is new](https://github.com/andresfrei/playbook/releases): the notes of every release.
- [The project wiki](docs/playbook/README.md): this repository builds Playbook with Playbook.

## Contributing

Issues and pull requests are welcome. Read the [contributing guide](CONTRIBUTING.md) first, and report vulnerabilities as [SECURITY.md](SECURITY.md) says.

Playbook is available under the [MIT License](LICENSE).
