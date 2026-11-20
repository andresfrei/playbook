# Codex CLI integration

The local checkout supplies a one-command installer (codex-support-3, codex-support-5, codex-support-8). Run `python3 codex/install.py` and choose the wiki or the wiki with agents. The installer packages shared sources, registers a local marketplace through the Codex CLI, preserves existing profiles and directs the user to review hooks in `/hooks`. See the [Codex guide](../../../codex/README.md).

The package carries `skeleton.md` for `prepare-project`. The Codex installer sets the working-agent models. The `config`, `protect`, and `seed-evidence` skills belong to Claude Code (setup-commands-7, codex-install-check-3).

The wiki contract loads at session start. The optional working agents use personal profiles. New profiles default to `gpt-6.2-sol` at low effort for explore, the same model at medium effort for write, and `gpt-6.2-astra` at high effort for review (codex-support-2, codex-support-4).

When the Codex review agent finishes, its stop hook records the completed review for the commit reminder and lets the report reach the caller, including any findings (codex-install-check-2).

During execution of a work, the main session records review findings on the work branch using the shared classification criteria. At close it counts evidence and recurring tasks with the enabled agents plugin. Approved task agents use project-local Codex TOML profiles (codex-install-check-3).

The public [README](../../../README.md) explains the shared workflow, links each plugin guide and separates client setup (codex-support-7, codex-support-13).

Before offering either installation, the installer checks Python 3.11+, the Unix tools used by the packager, Git, and support for the Codex plugin and marketplace commands it invokes. It reports the installed versions of Python, Git, and Codex. Run `python3 codex/install.py --check` for the same check on its own (codex-install-check-1).
