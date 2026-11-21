#!/bin/sh
# SessionStart: prints the rules, the project's wiki README when there is
# one, then the language the person chose (userConfig "language").
rules="${CLAUDE_PLUGIN_ROOT}/rules.md"
cat "$rules"
# The wiki lives at the root of the repository, also for a session started in
# one of its folders.
dir=${CLAUDE_PROJECT_DIR:-.}
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root=$dir
readme=$root/docs/playbook/README.md
if [ -f "$readme" ]; then
  # Hook output past 10,000 characters reaches Claude only as a file path,
  # so the rules and the README must fit together, with room for two lines.
  budget=$((9000 - $(wc -c < "$rules" | tr -d ' ')))
  if [ "$(wc -c < "$readme" | tr -d ' ')" -le "$budget" ]; then
    printf '\n# The wiki: docs/playbook/README.md\n\n'
    cat "$readme"
  else
    printf '\ndocs/playbook/README.md is over %s characters, too long to load with the rules: read it first, and shorten it.\n' "$budget"
  fi
fi
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf '\nTalk to the person in %s.\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
fi
