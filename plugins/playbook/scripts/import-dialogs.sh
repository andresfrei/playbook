#!/bin/sh
# Imports once the answered dialogs of Claude Code's transcripts into the file
# the capture hook writes, $CLAUDE_PLUGIN_DATA/dialogs.jsonl (dialog-learning-2).
#
# Usage:
#   sh import-dialogs.sh [PROJECTS_DIR]
#     PROJECTS_DIR defaults to ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects. Every
#     *.jsonl under it is read. A line is an answered dialog when it has
#     "type":"user" and a toolUseResult object with questions and answers; any
#     other line (a rejected call, another tool's result, invalid JSON) is ignored.
#     Each one is appended, in time order, as one compact line:
#       {"time":T,"origin":"import","input":{"session_id":S,"cwd":C,
#        "tool_name":"AskUserQuestion","tool_use_id":ID,"tool_response":R}}
#     A line with no "origin" is from the hook. An id (input.tool_use_id) already
#     in dialogs.jsonl, or repeated in the transcripts, is skipped, so a second run
#     adds none. Prints how many were imported and how many were already present.
#
# The transcript format "is internal to Claude Code and changes between versions"
# (sessions.md). When transcripts exist and none holds an answered dialog, it
# says so on stderr and writes nothing, since the import may need updating.
#
# Errors go to stderr with exit 1. Without jq it says so and writes nothing.
die() { printf 'import-dialogs: %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "jq is required and was not found on PATH; nothing was written"
[ -n "${CLAUDE_PLUGIN_DATA:-}" ] || die "CLAUDE_PLUGIN_DATA is not set; nothing was written"

dir=${1:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects}
out=$CLAUDE_PLUGIN_DATA/dialogs.jsonl

tmp=$(mktemp -d) || die "cannot create a temporary folder"
trap 'rm -rf "$tmp"' EXIT

[ -d "$dir" ] || die "no transcripts: '$dir' is not a folder"
find "$dir" -type f -name '*.jsonl' > "$tmp/files" 2>/dev/null
total=$(wc -l < "$tmp/files" | tr -d ' ')
[ "$total" -gt 0 ] || die "no transcripts: no .jsonl file under '$dir'"

# Answered dialogs of every transcript, one compact line each.
: > "$tmp/found"
while IFS= read -r f; do
  jq -R -c 'fromjson? // empty
    | select(type == "object" and .type == "user"
        and (.toolUseResult | type) == "object"
        and (.toolUseResult.questions | type) == "array"
        and (.toolUseResult.answers | type) == "object")
    | (first((.message.content | arrays | .[]? | select(type == "object" and .type == "tool_result") | .tool_use_id) // empty)) as $id
    | select($id != null)
    | {time: .timestamp, origin: "import",
       input: {session_id: .sessionId, cwd: .cwd, tool_name: "AskUserQuestion",
               tool_use_id: $id, tool_response: .toolUseResult}}' "$f" >> "$tmp/found" 2>/dev/null
done < "$tmp/files"

if [ ! -s "$tmp/found" ]; then
  printf 'import-dialogs: no answered AskUserQuestion was found in %s transcripts under %s. The transcript format is internal to Claude Code and changes between versions (sessions.md), so the import may need updating. Nothing was written.\n' "$total" "$dir" >&2
  exit 1
fi

# Ids already in dialogs.jsonl, from the hook or a previous import.
: > "$tmp/ids"
if [ -f "$out" ]; then
  jq -R -r 'fromjson? // empty | .input.tool_use_id? // empty | strings' "$out" > "$tmp/ids" 2>/dev/null
fi

# Time order, one line per id, none already present.
jq -s -c --rawfile ids "$tmp/ids" '
  ($ids | split("\n") | map({key: ., value: true}) | from_entries) as $have
  | sort_by(.time)
  | reduce .[] as $x ({seen: {}, new: [], present: 0};
      if .seen[$x.input.tool_use_id] then .
      elif $have[$x.input.tool_use_id] then .seen[$x.input.tool_use_id] = true | .present += 1
      else .seen[$x.input.tool_use_id] = true | .new += [$x] end)' "$tmp/found" > "$tmp/result" || die "cannot process the transcripts"

imported=$(jq -r '.new | length' "$tmp/result")
present=$(jq -r '.present' "$tmp/result")

if [ "$imported" -gt 0 ]; then
  mkdir -p "$CLAUDE_PLUGIN_DATA" || die "cannot create '$CLAUDE_PLUGIN_DATA'"
  jq -c '.new[]' "$tmp/result" >> "$out" || die "cannot write '$out'"
fi

printf 'imported %s dialogs, %s already present\n' "$imported" "$present"
