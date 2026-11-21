[![Playbook](docs/assets/playbook-banner.png)](https://playbook.neuralmind.lat/)

# Playbook

[![Latest release](https://img.shields.io/github/v/release/andresfrei/playbook?label=release&color=ff5a1f)](https://github.com/andresfrei/playbook/releases)
[![License: MIT](https://img.shields.io/github/license/andresfrei/playbook?color=ffb020)](LICENSE)

**[playbook.neuralmind.lat](https://playbook.neuralmind.lat/)** · Claude Code · by [NeuralMind](https://neuralmind.lat/)

Playbook is a free Claude Code plugin that helps you build fast without losing track. You decide what the software should do; Claude writes it down in your repository with your words, builds from it, and turns its repeated mistakes into project rules.

It adds only what Claude Code does not already do. Writing stays in your session, memory is Claude Code's auto memory, and parallel work is `/batch`.

## How a change goes

1. **Define.** `/playbook:define` names the type of change and runs only the steps it needs:

   | Type of change | Steps |
   |----------------|-------|
   | Small change | None: Claude just does it |
   | Feature on your current technology | Define |
   | Feature that adds or replaces a technology | Define, Technology, Skills |
   | New project | Define, Technology, Skills, and Design when it has an interface |

   It asks one question at a time, cites what you already decided instead of asking again, checks each technology in its current documentation, and writes a spec with how to check it. You accept the spec once.
2. **Build.** In your session, on the model you choose with `/model`.
3. **Close.** `/playbook:close` runs the spec's check, has a read-only `reviewer` read a risky change, and proposes one line for each mistake that happened twice, or each answer you gave twice: for `CLAUDE.md`, `.claude/rules/`, or a skill. You accept each line or not.
4. **Audit**, when you adopt a project, before a release, or when `close` suggests it. `/playbook:audit` reads the wiki against the code and against the tools your repository has on (plugins, MCP servers, skills), and shows each contradiction with both quotes; you say which side is right, and which tools the repository uses.
5. **Release.** `/playbook:release` sets the version and drafts the notes. Pushing, opening or merging a pull request, and publishing a release always ask you first.

Everything lives in `docs/playbook/`: the product, each work's spec, and its decisions with who decided and their words. Its `README.md` loads at the start of every session.

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

Then start a new session in your project and run `/playbook:audit`. On its first run it adopts the project: it reads the documentation and rules the project already has, proposes how to order them, builds the wiki in `docs/playbook/`, cleans `CLAUDE.md`, and records in the wiki the tools you say the repository uses, asking you each choice. It starts from a clean git tree, so all it changes is one diff. Until a project is adopted, each session in its git repository recommends it.

To make searches cheaper, copy [`plugins/playbook/extras/Explore.md`](plugins/playbook/extras/Explore.md) to `~/.claude/agents/`.

To keep Claude from reading secrets, add deny rules to `.claude/settings.json`. To be asked before a command that destroys work, add ask rules: they prompt in every permission mode, `bypassPermissions` included. The plugin asks before a push; a forced push, which rewrites the remote's history, gets its own rules as well, since a hook's filter is best-effort.

```json
{
  "permissions": {
    "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"],
    "ask": [
      "Bash(git reset --hard*)", "Bash(git clean *)", "Bash(rm -rf *)", "Bash(rm -fr *)",
      "Bash(git push -f*)", "Bash(git push * -f*)", "Bash(git push *--force*)"
    ]
  }
}
```

### From 4.x

Version 5 replaces the three plugins with one and moves the wiki to `docs/playbook/`. Uninstall the old plugins and update `playbook`:

```sh
claude plugin uninstall playbook-agents@playbook
claude plugin uninstall playbook-wiki@playbook
claude plugin marketplace update playbook
claude plugin update playbook@playbook
```

If `/playbook:init` turned them on for one repository only, run the two `uninstall` lines from that repository with `--scope local`.

Then run `/playbook:audit` in each project. It moves the 4.x wiki in `docs/wiki/` into `docs/playbook/`, keeping every decision and the owner's words; the check reads those decisions in their 4.x format.

## Documentation

- [What is new](https://github.com/andresfrei/playbook/releases): the notes of every release.
- [The project wiki](docs/playbook/README.md): this repository builds Playbook with Playbook.

## Contributing

Issues and pull requests are welcome. Read the [contributing guide](CONTRIBUTING.md) first, and report vulnerabilities as [SECURITY.md](SECURITY.md) says.

Playbook is available under the [MIT License](LICENSE).
