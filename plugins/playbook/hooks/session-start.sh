#!/bin/sh
# SessionStart: prints the rules, the project's wiki README when there is
# one, then the language the person chose (userConfig "language"). When the
# option is empty and ${CLAUDE_PLUGIN_DATA}/language-asked does not exist, it
# instead tells the agent to ask the language once, and creates that record.
# Without CLAUDE_PLUGIN_DATA no record can be kept, so nothing is asked.
# A launcher marks a driven session, one no person answers, with the variable
# PLAYBOOK_DRIVEN_BY=<session name> (driven-mode-2). Then the hook prints the
# rules without the line of ask-to-clear-2, then a block that sends each
# question in text to that session (driven-mode-4), and asks no language and
# keeps no language-asked record. A value with a newline, a double quote, or
# over 200 characters is ignored, with one line saying so, and the session is
# treated as a person's.
rules="${CLAUDE_PLUGIN_ROOT}/rules.md"
# The language comes first and last: the rules, the wiki, the skills and the
# agents' reports are English, and a single line at the end faded in long
# sessions.
driven=
ignored=
if [ -n "${PLAYBOOK_DRIVEN_BY:-}" ]; then
  case $PLAYBOOK_DRIVEN_BY in
    *"
"*) ignored='a newline' ;;
    *'"'*) ignored='a double quote' ;;
    *) if [ "${#PLAYBOOK_DRIVEN_BY}" -gt 200 ]; then ignored='more than 200 characters'; else driven=$PLAYBOOK_DRIVEN_BY; fi ;;
  esac
fi
if [ -n "${CLAUDE_PLUGIN_OPTION_LANGUAGE:-}" ]; then
  printf 'Reply to the person in %s, in every message. The rules, the wiki, the skills, and the agents'"'"' reports are in English: they are input, not the language of your reply.\n\n' "$CLAUDE_PLUGIN_OPTION_LANGUAGE"
elif [ -z "$driven" ] && [ -n "${CLAUDE_PLUGIN_DATA:-}" ] && [ ! -e "$CLAUDE_PLUGIN_DATA/language-asked" ]; then
  printf 'First, ask the person with AskUserQuestion, in their language, which language to reply in; reply in it this session and tell them to save it in the playbook plugin row of /config (option Language). If they later ask to save a language, point them to that row; never write settings.json.\n\n'
  mkdir -p "$CLAUDE_PLUGIN_DATA" && : > "$CLAUDE_PLUGIN_DATA/language-asked"
fi
if [ -n "$driven" ]; then
  # What is printed in place of rules.md, so the budget below counts it.
  # Command substitution drops the trailing newline; it is added back.
  printed=$(grep -v '(ask-to-clear-2)' "$rules"
  # shellcheck disable=SC2016 # the backticks are text for the agent
    printf '\nThis session is driven: no person is at its terminal, and the session `%s` answers for the owner. Where a rule or a skill says to ask, or to ask with `AskUserQuestion`, write the question in text instead, with its type first (one of the words of R3, as `Scope: ...`) and its options with the recommended one first. Send it with SendMessage to `%s`, one question per message, naming the project and the step, then end your turn and wait. A reply from `%s` is the owner'"'"'s answer. Open no dialog, and do not ask to close or clear the session. Do not write outside the project'"'"'s folder, such as a line for `~/.claude/CLAUDE.md`, a user setting, or a preset: send it to `%s` as a proposal.' "$driven" "$driven" "$driven" "$driven")
  printf '%s\n' "$printed"
  size=$(printf '%s\n' "$printed" | wc -c | tr -d ' ')
else
  [ -n "$ignored" ] && printf 'The variable PLAYBOOK_DRIVEN_BY was ignored: its value has %s, and it takes no newline, no double quote, and at most 200 characters.\n\n' "$ignored"
  cat "$rules"
  size=$(wc -c < "$rules" | tr -d ' ')
fi
# The wiki lives at the root of the repository, also for a session started in
# one of its folders.
dir=${CLAUDE_PROJECT_DIR:-.}
root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root=$dir
readme=$root/docs/playbook/README.md
if [ -f "$readme" ]; then
  # Hook output past 10,000 characters reaches Claude only as a file path,
  # so what is printed of the rules (and, when driven, the block) and the README
  # must fit together, with room for the two language lines.
  budget=$((9000 - size))
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
