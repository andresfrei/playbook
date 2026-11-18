# Installer architecture

Stage 2 design for codex-support-4 and codex-support-5. The owner approved the implementation approach in [codex-support-8](decisions.md). The current manual workflow packages two plugins, registers a local marketplace, installs the selection and copies agent profiles. The planned installer will bring these steps together. See the [existing workflow](../../../../codex/README.md).

## Existing technology

Verified locally on 2026-11-18 with `codex --version`, `python3 --version` and `git --version`: Codex CLI 0.170.0, Python 3.12.3 and Git 2.43.0. These are observed versions. The [packager](../../../../codex/package.sh) already uses sh and Python. The installed CLI help confirms that `codex plugin marketplace add` accepts a local path and `codex plugin add` accepts a plugin and marketplace name. Codex handles hook trust separately. [OpenAI plugin packaging](https://developers.openai.com/plugins/build/plugins)

## Installer design

| Need | Implementation |
|------|----------------|
| One command in a checkout | Run `python3 codex/install.py`. The installer takes the selection, invokes the existing packager in a fresh directory, and checks subprocess results before proceeding. Python is already required by both packages. [Python subprocess reference](https://docs.python.org/3/library/subprocess.html) |
| Install the selection | Register a persistent local marketplace and install the wiki first. For the full selection also install the agents plugin and its role files. Let the Codex CLI manage its plugin configuration. Report the hooks to trust after installation. |
| Apply the approved models | Extend the existing role generator with the model and effort in codex-support-4. Keep shared role instructions in their current source. |
| Preserve user settings | Create missing personal roles without replacing existing entries. Report a conflicting role by name. An existing profile may therefore retain a different model. Leave MCP and terminal settings under user control. |
| Recover from an interrupted installation | Report which step failed, keep the previous usable marketplace while preparing its replacement and allow retry. Verify both selections, an existing custom role and a rerun against an isolated Codex profile before delivery. |

The installer needs the local Codex CLI and shell toolchain. It uses Python's standard library and the existing local packaging flow. A second packaging system would duplicate the transformation already performed for the two plugins. The confirmed command syntax and packaged components are evidence for the design. End-to-end installer behaviour awaits execution in stage 6.
