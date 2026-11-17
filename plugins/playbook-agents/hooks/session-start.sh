#!/bin/sh
# Prints the rules at the start of a session, then one line with the language
# the person chose for the agent (userConfig "language"), when there is one.
cat "${CLAUDE_PLUGIN_ROOT}/rules.md"
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf 'Talk to the person in %s.\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
fi
