---
paths:
  - "plugins/playbook/.claude-plugin/plugin.json"
  - "docs/playbook/works/**"
---

# Versioning

- The version lives in `plugins/playbook/.claude-plugin/plugin.json` only (TD22). When a work closes, recommend whether it needs a version and ask the owner; on a yes, after the merge: the tag `v<version>` and the release on GitHub titled `playbook <version>` (github-release-1, github-release-2).
- Which kind of version a work needs is in the line `Versioning:` of `docs/playbook/technology.md` (audit-2026-11-24-7).
