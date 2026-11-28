#!/bin/sh
# PostToolUse of AskUserQuestion: stores each answered dialog (dialog-learning-2).
# It appends one line to $CLAUDE_PLUGIN_DATA/dialogs.jsonl: the UTC time and the
# hook's input as it arrived, with raw newlines removed (in valid JSON they are
# only whitespace). It parses nothing. With no data folder it writes nothing.
# It always exits 0 and prints nothing, so it never blocks an answer.
dir=${CLAUDE_PLUGIN_DATA:-}
if [ -n "$dir" ] && mkdir -p "$dir" 2>/dev/null; then
  input=$(tr -d '\n\r')
  time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  [ -n "$input" ] && printf '{"time":"%s","input":%s}\n' "$time" "$input" >> "$dir/dialogs.jsonl" 2>/dev/null
fi
exit 0
