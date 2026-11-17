# Contributing

This repository is a Claude Code product of three plugins, maintained by one person and shared as it is. Issues and pull requests are welcome. Every pull request is reviewed and approved by the owner before it is merged; nothing reaches `main` without that approval.

`playbook-wiki` is meant for anyone who works on a project with others. `playbook-agents` is the owner's own way of working, so a change to it can be declined even when it is correct, if it does not fit how the owner works. For anything larger than a small fix, open an issue first and wait for an answer before writing the change.

## Issues

Use one of the two templates: **Bug** for something that does not work as described, **Idea** for a proposal. Say which tool and version you use (Claude Code).

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
  shellcheck scripts/*.sh plugins/*/*.sh plugins/*/hooks/*.sh plugins/*/skills/*/scripts/*.sh
  ```

  `verify.sh` needs the `claude` command. The limits it enforces are in [docs/wiki/01-product/style-guide.md](docs/wiki/01-product/style-guide.md).

What is decided about the product is in [docs/wiki/decisions.md](docs/wiki/decisions.md). A change that contradicts a decision is discussed in an issue first.

## Releases

Each plugin declares its version in its manifest, `plugins/<name>/.claude-plugin/plugin.json`, with [Semantic Versioning](https://semver.org/). Only the owner changes it, when a release is made, and tags that commit `v<version>`:

- **MAJOR**: a change that breaks an existing installation, such as removing or renaming a skill, a command, or an agent.
- **MINOR**: something new that breaks nothing, such as a new skill or a new rule.
- **PATCH**: a fix to text or behaviour.

An installation from this repository's git address updates only when the version changes, so a commit merged between releases reaches users with the next release. Do not change the version in a pull request.

By contributing, you agree that your contribution is licensed under the [MIT License](LICENSE).
