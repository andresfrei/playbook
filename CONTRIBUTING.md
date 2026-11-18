# Contributing

Playbook is a set of plugins for Claude Code and Codex CLI, maintained by one person and shared as it is. Issues and pull requests are welcome. Every pull request is reviewed and approved by the owner before it is merged; nothing reaches `main` without that approval.

`playbook-wiki` is meant for anyone who works on a project with others. `playbook-agents` is the owner's own way of working, so a change to it can be declined even when it is correct, if it does not fit how the owner works. For anything larger than a small fix, open an issue first and wait for an answer before writing the change.

## Issues

Use one of the two templates: **Bug** for something that does not work as described, **Idea** for a proposal. Say which client and version you use.

Do not report a security problem in an issue. See [SECURITY.md](SECURITY.md).

## Pull requests

- Write code, documentation, and commit messages in English.
- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, and so on.
- A change in behaviour comes with its tests.
- Keep a pull request to one change. About 400 changed lines is a guide, not a cap.
- Before you open it, run the checks and make sure they pass:

  ```sh
  sh scripts/verify.sh
  sh scripts/verify_test.sh
  python3 -B codex/test_install.py -v
  shellcheck scripts/*.sh plugins/*/*.sh plugins/*/hooks/*.sh plugins/*/skills/*/scripts/*.sh codex/package.sh
  ```

  `verify.sh` needs the `claude` command. The limits it enforces are in [docs/wiki/01-product/style-guide.md](docs/wiki/01-product/style-guide.md).

What is decided about the product is in [docs/wiki/decisions.md](docs/wiki/decisions.md). A change that contradicts a decision is discussed in an issue first.

## Claude Code models and skill evaluations

To change the model or the effort of an agent, edit its line in `plugins/playbook-agents/models.conf`, then run:

```sh
sh scripts/set-models.sh
```

The script writes the values into `plugins/playbook-agents/agents/*.md`. Do not edit the `model` or `effort` lines in `plugins/playbook-agents/agents/*.md` by hand: `verify.sh` fails when they differ from `plugins/playbook-agents/models.conf`.

Evaluation cases call the model and are billed to your account, so run them by hand, before a change to a skill is accepted:

```sh
# one skill
claude plugin eval plugins/playbook-agents --tag write-skill --ablation none --max-cost-usd 1 --no-publish
# the whole suite, one plugin at a time
claude plugin eval plugins/playbook-wiki --scaffold --ablation none --max-cost-usd 2 --no-publish -j 3
claude plugin eval plugins/playbook-agents --ablation none --max-cost-usd 3 --no-publish -j 3
```

`--no-publish` keeps the report on this machine. Each skill has two cases under `plugins/playbook-wiki/evals/` or `plugins/playbook-agents/evals/`: one request that must load it and one that must not. `prepare-project` has two more: a request that starts a new phase, and one that starts a work in a repository with a wiki. That last case builds its repository with a script, `fixture.sh`, which runs only with `--scaffold`.

## Releases

Each plugin declares its version in its manifest, `plugins/<name>/.claude-plugin/plugin.json`, with [Semantic Versioning](https://semver.org/). Only the owner changes it, when a release is made, and tags that commit `v<version>`:

- **MAJOR**: a change that breaks an existing installation, such as removing or renaming a skill, a command, or an agent.
- **MINOR**: something new that breaks nothing, such as a new skill or a new rule.
- **PATCH**: a fix to text or behaviour.

Then create the release on GitHub for that tag, titled `playbook <version>`, with notes on what changed and, for a MAJOR version, how to move from the one before. A tag alone is not listed under "Releases":

```sh
gh release create v<version> --verify-tag --title "playbook <version>" --notes-file <notes.md>
```

An installation from this repository's git address updates only when the version changes, so a commit merged between releases reaches users with the next release. Do not change the version in a pull request.

By contributing, you agree that your contribution is licensed under the [MIT License](LICENSE).
