# Decisions

| ID | Date | Decision | Who decided | Their words | Shared page | Kind | Answer |
|----|------|----------|-------------|-------------|-------------|------|--------|
| codex-install-check-1 | 2026-11-20 | Check requirements before installation and on demand with `--check`. Require Python 3.11+, report Git and Codex versions, check the required Unix tools and Codex plugin commands, and stop only for a failed requirement. | Andres Frei | “podemos poner un comprbador de versiones necesarias?” and “si... estas usando los plugins, la wiki y los agentes?” | `03-technology/codex.md` | definition | as recommended |
| codex-install-check-2 | 2026-11-20 | In Codex, let the review agent finish with its findings and record that the review ran. The installed review workflow uses the three documented profiles. | Andres Frei | “avancemos en eso” | `03-technology/codex.md` | definition | as recommended |
| codex-install-check-3 | 2026-11-20 | Complete the Codex evidence and recurring-task workflow with the supported profiles. Package the shared scripts and exclude the Claude-only protection and transcript-seeding skills. | Andres Frei | “podes corregirlo?” | `03-technology/codex.md` | definition | as recommended |
| codex-install-check-4 | 2026-11-20 | Create a local branch and commit the verified Codex changes. Keep the personal permissions file outside the commit. | Andres Frei | “si” | none | commit | as recommended |
| codex-install-check-5 | 2026-11-20 | Release Playbook 3.7.0 with the three Claude Code and two Codex plugin manifests aligned. Tag the release commit and publish the release notes on GitHub. | Andres Frei | “si” | `03-technology/codex.md` | version | as recommended |
