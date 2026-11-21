# Technology of the work claude-code-versions

Checked on 2026-11-20 by running each command in this repository.

| Need | Technology | Source | Status |
|------|------------|--------|--------|
| N1. Read the installed version | `claude --version`, which prints `2.1.330 (Claude Code)` | Run on 2026-11-20 | Already in use |
| N2. Read the changelog verbatim | `curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`, 11 661 lines; versions are `## X.Y.Z` headings, newest first. `curl` is already used by `docs/assets/render-demo.sh` | Fetched on 2026-11-20 | Decided (claude-code-versions-7) |
| N3. Keep only the versions after the record | `awk -v from=<recorded> '/^## /{ if ($2 == from) exit } { print }'`: prints every section above the recorded version. 2.1.330 alone is 145 lines; 2.1.326 to 2.1.330 is about 970 | Run on 2026-11-20 | Decided (claude-code-versions-7) |
| N4. Run the evaluation when the owner asks | A project skill, `.claude/skills/evaluate-cli-releases/SKILL.md`: it triggers on the owner's words and can be called as `/evaluate-cli-releases` | Recalled from Claude Code's skills documentation, not checked this session | Decided (claude-code-versions-7) |
| N5. Cross the changelog with the repository without filling the session | The `explore` agent of `playbook-agents`, read-only, gets the extracted sections and the repository's paths and returns the table | [architecture.md](architecture.md) | Decided (claude-code-versions-7) |

No new dependency.
