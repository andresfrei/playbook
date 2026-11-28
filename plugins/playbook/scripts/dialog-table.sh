#!/bin/sh
# Prints the table by type of the answered dialogs, and the departures of one
# project, from $CLAUDE_PLUGIN_DATA/dialogs.jsonl (dialog-learning-6).
#
# Usage:
#   sh dialog-table.sh PROJECT_DIR [TYPES_FILE]
#     PROJECT_DIR: the project the departures are listed for. A line belongs to it
#     when its input.cwd is PROJECT_DIR or under it (/a/bc is not under /a/b).
#     TYPES_FILE (optional): JSON lines {"id":tool_use_id,"question":text,"type":word}
#     written by the reading subagent; it types a question whose header is not one
#     of the fourteen words (dialog-learning-3). Invalid lines are skipped.
#
# Each line of dialogs.jsonl is {"time","origin"?,"input":{cwd,tool_use_id,
# tool_response:{questions,answers}}}: no origin is the hook, "import" the import.
# The shape is not documented and may change: a line or a question without those
# fields, and any invalid JSON line, is skipped, not an error.
#
# One row per question. Its type is its header when it is one of the fourteen
# words, else the TYPES_FILE word for that id and question, else "untyped".
# "First option": the answer equals options[0].label; otherwise it "departed".
# "Own words": the answer is no option label (for multiSelect, not made only of
# labels, commas, and spaces; a label may hold a comma).
#
# Output, plain text, in this order:
#   1. "Answered dialogs, every project" and a markdown table
#      | Type | Asked | First option | Projects |
#      the fourteen types in order, then untyped; rows with Asked > 0 only;
#      First option is a rounded percent; Projects counts the distinct cwd
#      values that are under no other cwd of the row, so a subfolder or a
#      worktree inside a project is that project.
#      The counts cover every project in the file.
#   2. "Own-words answers in PROJECT_DIR: N"
#   3. "Departures in PROJECT_DIR" (PROJECT_DIR only, in time order), each:
#        - TIME [Type] QUESTION
#          options: A (recommended) / B / C
#          answer: TEXT
#   4. When any question of any project is untyped: "Untyped questions", then a
#      fenced block of JSON lines {id, question, header, options, answer}, one per
#      untyped question, for the subagent to classify into TYPES_FILE.
#
# Errors go to stderr with exit 1: no jq, CLAUDE_PLUGIN_DATA unset, no
# dialogs.jsonl, no PROJECT_DIR, or an unreadable TYPES_FILE.
die() { printf 'dialog-table: %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || die "jq is required and was not found on PATH"
[ -n "${CLAUDE_PLUGIN_DATA:-}" ] || die "CLAUDE_PLUGIN_DATA is not set"
[ -n "${1:-}" ] || die "usage: dialog-table.sh PROJECT_DIR [TYPES_FILE]"

dir=$1
types=${2:-}
file=$CLAUDE_PLUGIN_DATA/dialogs.jsonl
[ -f "$file" ] || die "no dialogs: '$file' does not exist"
if [ -n "$types" ] && [ ! -r "$types" ]; then die "cannot read '$types'"; fi

tmp=$(mktemp -d) || die "cannot create a temporary folder"
trap 'rm -rf "$tmp"' EXIT

: > "$tmp/types"
if [ -n "$types" ]; then
  jq -R -c 'fromjson? // empty | select(type == "object")' "$types" > "$tmp/types" 2>/dev/null
fi

jq -R -c 'fromjson? // empty | select(type == "object")' "$file" > "$tmp/lines" 2>/dev/null

jq -r -s --arg dir "$dir" --slurpfile typed "$tmp/types" '
  ["Session","Accept","Delivery","Load","Record","Finding","Remote","Setup",
   "Product","Technical","Design","Scope","Problem","Clarify"] as $words
  | ($dir | sub("/+$"; "")) as $d
  | ($typed | map(select((.id | type) == "string" and (.question | type) == "string"
        and (.type as $t | $words | index($t))))
     | map({key: (.id + "\u0000" + .question), value: .type}) | from_entries) as $tmap
  | [ .[]
      | select((.input | type) == "object" and (.input.tool_response | type) == "object"
          and (.input.cwd | type) == "string" and (.input.tool_use_id | type) == "string"
          and (.input.tool_response.questions | type) == "array"
          and (.input.tool_response.answers | type) == "object")
      | .time as $time | .input.cwd as $cwd | .input.tool_use_id as $id
      | .input.tool_response.answers as $answers
      | .input.tool_response.questions[]
      | select(type == "object" and (.question | type) == "string"
          and (($answers[.question]) | type) == "string")
      | . as $q
      | ([.options[]? | select(type == "object") | .label | strings]) as $labels
      | $answers[$q.question] as $a
      | (reduce ($labels | sort_by(-length) | .[]) as $l ($a; split($l) | join(""))
         | test("^[\\s,]*$")) as $madeoflabels
      | {time: $time, cwd: $cwd, id: $id, question: $q.question,
         header: (if ($q.header | type) == "string" then $q.header else "" end),
         labels: $labels, answer: $a,
         first: (($labels | length) > 0 and $a == $labels[0]),
         own: (($labels | index($a)) == null
               and (($q.multiSelect == true | not) or ($madeoflabels | not)))}
      | .header as $h
      | .type = (if ($words | index($h)) != null then $h
                 else ($tmap[.id + "\u0000" + .question] // "untyped") end)
      | .in = ($cwd == $d or ($cwd | startswith($d + "/")) or $d == "")
    ] as $rows
  | ($words + ["untyped"]) as $order
  | "Answered dialogs, every project",
    "",
    "| Type | Asked | First option | Projects |",
    "|------|-------|--------------|----------|",
    ( $order[] as $t
      | [$rows[] | select(.type == $t)] as $r
      | select(($r | length) > 0)
      | "| \($t) | \($r | length) | \((($r | map(select(.first)) | length) * 100 / ($r | length) + 0.5 | floor))% | \($r | map(.cwd) | unique | . as $c | map(select(. as $x | $c | any(. as $p | $p != $x and ($x | startswith($p + "/"))) | not)) | length) |" ),
    "",
    "Own-words answers in \($dir): \([$rows[] | select(.in and .own)] | length)",
    "",
    "Departures in \($dir)",
    "",
    ( [$rows[] | select(.in and (.first | not))] | sort_by(.time) | .[]
      | "- \(.time) [\(.type)] \(.question)",
        "  options: \(.labels | to_entries | map(if .key == 0 then "\(.value) (recommended)" else .value end) | join(" / "))",
        "  answer: \(.answer)" ),
    ( [$rows[] | select(.type == "untyped")] as $u
      | select(($u | length) > 0)
      | "",
        "Untyped questions",
        "",
        "```",
        ($u[] | {id, question, header, options: .labels, answer} | tojson),
        "```" )
' "$tmp/lines" || die "cannot process '$file'"
