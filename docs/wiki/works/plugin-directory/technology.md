# Technology of plugin-directory

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency.

Sources, read on 2026-11-17, in addition to those of [definition.md](definition.md):

- https://code.claude.com/docs/en/plugins-reference
- https://code.claude.com/docs/en/plugins/dependencies.md
- https://code.claude.com/docs/en/plugins/marketplace-reference
- https://code.claude.com/docs/en/plugins/install.md

Checked by running, on 2026-11-17: `claude plugin validate` (Claude Code 2.1.326) on each plugin, and ImageMagick 6.9.12, which reads and writes SVG.

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | A README of at least 40 words and a licence inside each plugin folder; the directory "reads and scans only that folder", and the check blocks without them | A `README.md` in `plugins/playbook-wiki/` and `plugins/playbook-agents/`, and `"license": "MIT"` in each `plugin.json`, which the check accepts in place of a file | Decided (plugin-directory-5) |
| N2 | `playbook-agents` brings `playbook-wiki` (plugin-directory-1) | Keep `"dependencies": ["playbook-wiki"]`. A bare name "resolves against this plugin's own marketplace"; the docs do not say how it resolves in the directory. Checked after the listing, by installing `playbook-agents` from the directory | Decided (plugin-directory-5) |
| N3 | No submitted plugin depends on the marketplace name `playbook` | Nothing to change: no file of `playbook-wiki` or `playbook-agents` names it, checked by search. Only `playbook`, not submitted, does | Decided (plugin-directory-5) |
| N4 | Hook commands the check can follow | Keep `sh "${CLAUDE_PLUGIN_ROOT}/..."` and `cat "${CLAUDE_PLUGIN_ROOT}/..."`: the check blocks another variable, a command substitution, a wildcard, or an inline program, and names no interpreter before the path. The portal's Validate decides; changed only if it blocks | Decided (plugin-directory-5) |
| N5 | Hook scripts the reviewer accepts | Keep the scripts as they are, and accept that each version is held for a reviewer: seven scripts use command substitution, and two read `hooks/git-hook-lib.sh`. A reviewer publishes each version by default anyway | Decided (plugin-directory-5) |
| N6 | The icons (plugin-directory-3) | An SVG written by hand for each plugin, turned into a 512 px PNG with ImageMagick, at `.claude-plugin/icon.png`, where the validator looks | Decided (plugin-directory-5) |
| N7 | What the security scan and the policy ask to be disclosed | Each plugin's `README.md` says what each hook reads, prints, and stops, that nothing leaves the machine, and gives three example prompts. Support: the repository's GitHub issues, and the contact email the owner gives in the portal. No privacy policy: no data is collected or sent | Decided (plugin-directory-5) |

## Architecture

The product does not change shape: the same three plugins in the marketplace `playbook`. The work adds files inside two plugin folders, a `README.md` and an icon, and one field to two manifests. No script or hook changes.

The directory is a second way in (plugin-directory-2): it takes each plugin folder from this repository's default branch and lists it.

Risks:

- The directory may not resolve `playbook-agents`'s dependency: someone installs it without `playbook-wiki`. Reduced by checking it after the listing (N2), and by the README of `playbook-agents` saying that it needs `playbook-wiki`.
- The policy forbids software that tries "to make any changes to Claude's behavior across sessions". The SessionStart hooks print the contract and the rules in each session. Reduced by disclosing it in the README (N7); the reviewer decides.
- The scan or the reviewer holds or rejects a version. Reduced by the portal's Validate before submitting.

Trade-offs: N5 keeps the scripts readable and tested, and gives up publication without a reviewer.

Discarded: rewriting the scripts without command substitution, which POSIX shell cannot do for what they read from git; submitting the marketplace as a whole, which the directory does not accept.

Not applicable: data and volume, since nothing new is stored.
