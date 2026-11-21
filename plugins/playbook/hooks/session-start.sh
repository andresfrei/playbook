#!/bin/sh
# SessionStart: prints the rules, the project's wiki README when there is
# one, then the language the person chose (userConfig "language").
cat "${CLAUDE_PLUGIN_ROOT}/rules.md"
readme="${CLAUDE_PROJECT_DIR:-.}/docs/wiki/README.md"
if [ -f "$readme" ]; then
  # Hook output past 10,000 characters reaches Claude only as a file path.
  if [ "$(wc -c < "$readme")" -le 6000 ]; then
    printf '\n# The wiki: docs/wiki/README.md\n\n'
    cat "$readme"
  else
    printf '\ndocs/wiki/README.md is over 6000 characters: read it first, and shorten it.\n'
  fi
fi
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf '\nTalk to the person in %s.\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
fi
