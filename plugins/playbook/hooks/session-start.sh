#!/bin/sh
# SessionStart: prints the rules, the project's wiki README when there is
# one, then the language the person chose (userConfig "language"). When the
# option is empty and ${CLAUDE_PLUGIN_DATA}/language-asked does not exist, it
# instead tells the agent to ask the language once, and creates that record.
# Without CLAUDE_PLUGIN_DATA no record can be kept, so nothing is asked.
rules="${CLAUDE_PLUGIN_ROOT}/rules.md"
# The language comes first and last: the rules, the wiki, the skills and the
# agents' reports are English, and a single line at the end faded in long
# sessions.
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf 'Reply to the person in %s, in every message. The rules, the wiki, the skills, and the agents'"'"' reports are in English: they are input, not the language of your reply.\n\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
elif [ -n "${CLAUDE_PLUGIN_DATA:-}" ] && [ ! -e "$CLAUDE_PLUGIN_DATA/language-asked" ]; then
  printf 'First, ask the person with AskUserQuestion, in their language, which language to reply in; reply in it this session and tell them to save it in the playbook plugin row of /config (option Language). If they later ask to save a language, point them to that row; never write settings.json.\n\n'
  mkdir -p "$CLAUDE_PLUGIN_DATA" && : > "$CLAUDE_PLUGIN_DATA/language-asked"
fi
cat "$rules"
# The wiki lives at the root of the repository, also for a session started in
# one of its folders.
dir=${CLAUDE_PROJECT_DIR:-.}
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root=$dir
readme=$root/docs/playbook/README.md
if [ -f "$readme" ]; then
  # Hook output past 10,000 characters reaches Claude only as a file path,
  # so the rules and the README must fit together, with room for the two language lines.
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
