# Working skills for Codex support

Accepted in [codex-support-10](decisions.md). The installed skills and existing project checks cover the [installer design](technology.md) and the public README task.

| Technology or task | Skill | Location | When to use it |
|--------------------|-------|----------|----------------|
| Python standard library, shell packaging and TOML role generation | `playbook-agents:keep-minimal` | [Skill](../../../../plugins/playbook-agents/skills/keep-minimal/SKILL.md) | Implement the installer and model defaults. Verify behaviour with isolated install and retry tests. |
| Codex CLI, plugin manifests and hooks | `openai-docs` | Codex system skills | Check client behaviour against official documentation and the installed CLI when a compatibility question arises. |
| Git fixtures and wiki validation | No dedicated skill needed | [Wiki validator](../../../../plugins/playbook-wiki/check-wiki.sh) and [repository checks](../../../../scripts/verify.sh) | Exercise commit and merge behaviour in temporary repositories. |
| Changes affecting user profiles or existing installations | `playbook-agents:review-change` | [Skill](../../../../plugins/playbook-agents/skills/review-change/SKILL.md) | Review the diff for partial installs, retries and accidental overwrites before delivery. |
| Markdown documentation | `playbook-wiki:write-docs` | [Skill](../../../../plugins/playbook-wiki/skills/write-docs/SKILL.md) | Update the wiki and simplify the public README after verifying the installer. |
| Work stages | `playbook-wiki:prepare-project` | [Skill](../../../../plugins/playbook-wiki/skills/prepare-project/SKILL.md) | Record decisions, validate the wiki and track stage closure. |
