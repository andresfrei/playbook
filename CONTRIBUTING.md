# Contributing

Playbook is a Claude Code plugin, maintained by one person and shared as it is. Issues and pull requests are welcome. Every pull request is reviewed and approved by the owner before it is merged; nothing reaches `main` without that approval.

Playbook adds only what Claude Code does not already do, and every piece is justified by Claude Code's documentation. A change that adds a piece can be declined even when it is correct. For anything larger than a small fix, open an issue first and wait for an answer before writing the change.

## Issues

Use one of the two templates: **Bug** for something that does not work as described, **Idea** for a proposal. Say which version of Claude Code you use.

Do not report a security problem in an issue. See [SECURITY.md](SECURITY.md).

## Pull requests

- Write code, documentation, and commit messages in English.
- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, and so on.
- A change in behaviour comes with its tests.
- Keep a pull request to one change. About 400 changed lines is a guide, not a cap.
- Before you open it, run the checks and make sure they pass:

  ```sh
  sh tests/check-wiki_test.sh
  sh tests/hooks_test.sh
  sh plugins/playbook/scripts/check-wiki.sh docs/playbook
  shellcheck plugins/playbook/hooks/*.sh plugins/playbook/scripts/*.sh tests/*.sh
  claude plugin validate .
  ```

What is decided about the product is in [docs/playbook/](docs/playbook/README.md). A change that contradicts a decision is discussed in an issue first.

## Releases

The plugin declares its version in its manifest, `plugins/playbook/.claude-plugin/plugin.json`, with [Semantic Versioning](https://semver.org/). Only the owner changes it, when a release is made, and tags that commit `v<version>`:

- **MAJOR**: a change that breaks an existing installation, such as removing or renaming a skill, a command, or an agent.
- **MINOR**: something new that breaks nothing, such as a new skill or a new rule.
- **PATCH**: a fix to text or behaviour.

Then create the release on GitHub for that tag, titled `playbook <version>`, with notes on what changed and, for a MAJOR version, how to move from the one before. A tag alone is not listed under "Releases":

```sh
gh release create v<version> --verify-tag --title "playbook <version>" --notes-file <notes.md>
```

An installation from this repository's git address updates only when the version changes, so a commit merged between releases reaches users with the next release. Do not change the version in a pull request.

By contributing, you agree that your contribution is licensed under the [MIT License](LICENSE).
