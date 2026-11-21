# Technology of version-check

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: a POSIX shell script that reads files with `sed` and `awk`, as the hooks of `playbook-wiki` already do. Documentation checked on 2026-11-19; sources at the end.

## Needs and choices

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | The installed version (version-check-6) | `version` of `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`. `CLAUDE_PLUGIN_ROOT` is a documented variable every plugin hook receives, pointing to the installed version's own folder. Only `playbook-wiki`'s version is compared: a release sets the same version in the three manifests (github-release-2), so one number stands for the three | Decided (version-check-9) |
| N2 | The available version, from the machine only (version-check-2) | `version` of `plugins/playbook-wiki/.claude-plugin/plugin.json` in the marketplace's local copy. The copy is `~/.claude/plugins/marketplaces/<marketplace>/` for a marketplace from Git or a URL; for one from a local folder, its path is the `installLocation` recorded in `~/.claude/plugins/known_marketplaces.json`. The marketplace's name is the folder above the plugin's in `CLAUDE_PLUGIN_ROOT` (`cache/<marketplace>/<plugin>/<version>/`) | Decided (version-check-9) |
| N3 | Compare two versions | `awk`, number by number of `MAJOR.MINOR.PATCH`. Anything that is not three numbers counts as unknown, and nothing is printed | Decided (version-check-9) |
| N4 | A wiki at a newer format than the plugin (version-check-8) | `wiki-format.sh hook` gets the case it lacks: the wiki's marker above the plugin's format. It recommends updating the plugin. `status` stays as it was, since the doctor, `init`, and Codex read its text | Decided (version-check-9, version-check-16) |
| N5 | The doctor after the update (version-check-5) | The format notice that already exists, unchanged in what it detects; it now reaches the person too (N6) | Decided (version-check-9) |
| N6 | Reach the person and the agent (version-check-3) | One JSON object on stdout: `systemMessage` for the person and `hookSpecificOutput.additionalContext` for the agent. Tried on 2026-11-19 in a real session: the person saw "SessionStart:startup says: …" before writing, and the agent answered from the context of the same output. The texts are fixed sentences with version numbers, so no escaping is needed | Decided (version-check-9) |
| N7 | Every session, and fast (version-check-4) | A SessionStart hook with the matcher `startup`, so it does not repeat on `resume`, `clear`, or `compact` of the same session. Only local files are read; on any missing file or unreadable value it prints nothing and exits 0 | Decided (version-check-9) |
| N8 | Tests | Cases in `scripts/verify_test.sh` with a fake `CLAUDE_PLUGIN_ROOT` and a fake plugins folder: older, equal, newer, unknown, missing copy, folder marketplace, wiki ahead and behind; `shellcheck` | Decided (version-check-9) |

## Architecture

The problem: a person keeps an old version of the playbook without knowing, and after an update nothing tells the person, as opposed to the agent, to run the doctor.

The shape: one hook at the start of a session compares two files already on the machine, and the format notice that exists reaches the person as well.

| Module | Changes | Does not |
|--------|---------|----------|
| `plugins/playbook-wiki/hooks/version-check.sh`, new | Reads N1 and N2, compares them (N3), and prints the notice as JSON (N6) | Connect to a network; update anything; store anything |
| `plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh` | The case of a wiki ahead of the plugin (N4); the hook's output as JSON for the person and the agent (N5, N6) | Change `mark` or what makes a wiki behind |
| `plugins/playbook-wiki/hooks/hooks.json` | The new hook under SessionStart with the matcher `startup` (N7); the format notice moves to the same matcher | Change the contract's hook, which still runs on every SessionStart |
| `plugins/playbook-wiki/README.md` | The new hook in its table of hooks; the promise that nothing connects to a network stays true | |
| `scripts/verify_test.sh` | The cases of N8 | |

Data: two version strings and one format number, all read from files. Nothing is written.

Outside systems: none. Claude Code's files are read, not changed.

Risks:

- The layout of `~/.claude/plugins/` changes in a later Claude Code. The folders are documented, but not as a stable interface for hooks; `known_marketplaces.json` least of all. Reduced by printing nothing when a file or value is missing: the notice goes silent, the session is never stopped.
- A person who installed from GitHub and never refreshes the marketplace is not told (version-check-8).
- The notice shows on every start while the versions differ, which a person staying on purpose on an old version sees each time (version-check-4).

Trade-offs:

- Reading Claude Code's own files gains a notice with no network, and gives up on the stability of a documented interface.
- One version for the three plugins gains one line and one comparison, and assumes the three are released together, as github-release-2 says.

Discarded:

- A request to GitHub: version-check-2.
- A version check in each plugin: version-check-6.
- A list of steps per version: version-check-5.

How it can evolve: the check against GitHub, off unless the person turns it on (version-check-8), reads `CLAUDE_PLUGIN_DATA` for a daily cache and adds one source to N2.

## Sources

- https://code.claude.com/docs/en/hooks: plain stdout of SessionStart goes to Claude's context; `systemMessage`, "Warning message shown to the user"; `additionalContext`; the cap of 10,000 characters; the matchers `startup`, `resume`, `clear`, `compact`, `fork`.
- https://code.claude.com/docs/en/plugins/loading.md: "When auto-update runs"; "Find plugins on disk", with `cache/<marketplace>/<plugin>/<version>/`, `marketplaces/<name>/`, `installed_plugins.json`, and `known_marketplaces.json`.
- https://code.claude.com/docs/en/plugins/components.md: every plugin hook receives `CLAUDE_PLUGIN_ROOT` and `CLAUDE_PLUGIN_DATA`.
- https://code.claude.com/docs/en/plugins/cli-reference.md: after `plugin update`, "The new version loads in your next session, or after you run `/reload-plugins`". Whether SessionStart runs again on `/reload-plugins` is not documented.
