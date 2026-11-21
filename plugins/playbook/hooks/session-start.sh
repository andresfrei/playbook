#!/bin/sh
# SessionStart: prints the rules, then the language the person chose
# (userConfig "language"), when there is one.
cat "${CLAUDE_PLUGIN_ROOT}/rules.md"
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf 'Talk to the person in %s.\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
fi
