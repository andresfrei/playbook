# Codex CLI integration

The local checkout supplies a one-command installer (codex-support-3, codex-support-5, codex-support-8). Run `python3 codex/install.py` and choose the wiki or the wiki with agents. The installer packages shared sources, registers a local marketplace through the Codex CLI, preserves existing profiles and directs the user to review hooks in `/hooks`. See the [Codex guide](../../../codex/README.md).

The wiki contract loads at session start. The optional working agents use personal profiles. New profiles default to `gpt-6.2-sol` at low effort for explore, the same model at medium effort for write, and `gpt-6.2-astra` at high effort for review (codex-support-2, codex-support-4).

The public [README](../../../README.md) explains the shared workflow, links each plugin guide and separates client setup (codex-support-7, codex-support-13).
