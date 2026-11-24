---
paths:
  - "plugins/playbook/.claude-plugin/plugin.json"
  - "docs/playbook/works/**"
---

# Versioning

- The version lives in `plugins/playbook/.claude-plugin/plugin.json` only (TD22). When a work closes, recommend whether it needs a version and ask the owner; on a yes, after the merge: the tag `v<version>` and the release on GitHub titled `playbook <version>` (github-release-1, github-release-2).
- When a work only changes rules, skills, or the README text of the plugin, recommend PATCH; MINOR is for a new skill, agent, hook, or script (the owner chose PATCH over a recommended MINOR in builder-load and ask-to-clear). Removing or renaming a skill is MINOR, not MAJOR (the owner chose MINOR over a recommended MAJOR in one-audit).
