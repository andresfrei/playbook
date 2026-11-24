# Technology

| Need | Technology | Why | Decision |
|------|------------|-----|----------|
| Run inside the person's agent | A Claude Code plugin, `playbook`, published from this repository's marketplace | Claude Code only; one plugin, since no user takes half of it | TD1, basics-3, basics-9 |
| Hooks and checks | Plain shell, with no extra tool | A person who installs the plugin installs nothing else | TD2 |
| Versions | Semantic Versioning in the plugin's `plugin.json` only, a tag `v<version>` per release, and a release on GitHub titled `playbook <version>` | Users know what changed; a MAJOR version says how to move from the one before | TD22, github-release-1 |
| Close of a work | The agent recommends whether it needs a version and which one, and asks the owner | | github-release-2 |

Delivery default: one branch and one pull request per work (delivery-versioning-2).

Versioning: the plugin's version in `plugins/playbook/.claude-plugin/plugin.json` only; after the merge of each work, `close` recommends whether it needs a tag and the owner decides (delivery-versioning-3, TD22, github-release-2).

Install: `claude plugin marketplace add andresfrei/playbook`, then `claude plugin install playbook@playbook`. A marketplace added from a local clone loads the plugin in place: a change applies to the next session, or after `/reload-plugins`.

The product is not listed in Anthropic's plugin directory, which accepts command hooks only from a Verified organization (plugin-directory-9).

## Claude Code versions

The project skill `.claude/skills/evaluate-cli-releases/` reads and writes this section when the owner asks to evaluate Claude Code (claude-code-versions-5).

Last version evaluated: 2.1.331

| Date | Versions read | Proposals | Where each went |
|------|---------------|-----------|-----------------|
| 2026-11-20 | 2.1.326 to 2.1.330 | None (claude-code-versions-12) | |
| 2026-11-23 | 2.1.331 | None (claude-code-versions-12) | |

### Pending

| Version | Change | What it touches | Proposal | Left on |
|---------|--------|-----------------|----------|---------|
