# Spec of the work reply-language

Status: Accepted (reply-language-5)

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

The plugin keeps the language of the replies in its `userConfig` option `language`, and the session-start hook puts it first and last in the context. Claude Code prompts for that option only when the plugin is enabled ("values Claude Code prompts the user for when the plugin is enabled", plugins-reference), so an owner who skipped it never sets it: the owner's own `pluginConfigs` is empty, and the sessions start with no language line. The plugin asks for it once instead (reply-language-1, reply-language-3).

## What changes

1. **The setting stays.** The language lives in `userConfig.language`, read by the hook as `CLAUDE_PLUGIN_OPTION_LANGUAGE`, edited by the owner in `/config` (reply-language-1).
2. **Asked once.** When the option is empty and the plugin has no record of having asked, the session-start hook tells the agent to ask the owner, with `AskUserQuestion`, which language to reply in, to reply in it for that session, and to tell the owner to save it in the plugin's row of `/config`. The hook then keeps a record of having asked in `${CLAUDE_PLUGIN_DATA}`. With the record, an empty option means following the language the owner writes in, as today. When the record is lost, the question comes back (reply-language-2, reply-language-3).
3. **Saving on request.** When the owner asks to save a language, the agent tells them the plugin's row of `/config`; it does not write `settings.json` (reply-language-4).
4. **The words.** The option's description in `plugin.json` and the row `userConfig` of `product.md` say the language is asked once when empty.

## Out of scope

- Claude Code's own setting `language` (reply-language-1).
- The agent writing `pluginConfigs` in the owner's `settings.json` (reply-language-2).

## Check

- `tests/hooks_test.sh` covers: an empty option with no record prints the instruction to ask and creates the record; an empty option with the record prints no language line; a set option prints its two lines as today.
- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`, `shellcheck`, and `claude plugin validate .`.
- Live check: in a throwaway repository with an empty `CLAUDE_PLUGIN_DATA`, `claude -p --plugin-dir plugins/playbook "hola"` asks the language; a second run does not.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| U1 | Points 2 to 4 above, with their tests | The checks above | Done |
