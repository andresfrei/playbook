#!/bin/sh
# Tests of plugins/playbook/scripts/import-dialogs.sh. Run from the repository root.
script=$PWD/plugins/playbook/scripts/import-dialogs.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0

ok() { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; failed=1; }
# when NAME CMD...: ok when the command succeeds.
when() { n=$1; shift; if "$@"; then ok "$n"; else bad "$n"; fi; }
# dlg TIME ID SESSION CWD QUESTION: an answered dialog line of a transcript.
dlg() {
  printf '{"type":"user","cwd":"%s","sessionId":"%s","timestamp":"%s","toolUseResult":{"questions":[{"question":"%s","header":"h","options":[{"label":"A","description":"d"}],"multiSelect":false}],"answers":{"%s":"A"}},"message":{"content":[{"type":"tool_result","tool_use_id":"%s"}]}}\n' "$4" "$3" "$1" "$5" "$5" "$2"
}

proj=$tmp/projects
mkdir -p "$proj/-a" "$proj/-b/sub/deep"
{
  dlg 2026-11-28T02:00:00.000Z toolu_2 s1 /a "second?"
  dlg 2026-11-28T01:00:00.000Z toolu_1 s1 /a "first?"
  printf '{"type":"user","timestamp":"2026-11-28T01:30:00.000Z","toolUseResult":"rejected","message":{"content":[{"type":"tool_result","tool_use_id":"toolu_r"}]}}\n'
  printf 'not json {\n'
} > "$proj/-a/one.jsonl"
{
  printf '{"type":"user","timestamp":"2026-11-28T01:40:00.000Z","toolUseResult":{"stdout":"x"},"message":{"content":[{"type":"tool_result","tool_use_id":"toolu_b"}]}}\n'
  dlg 2026-11-28T03:00:00.000Z toolu_3 s2 /b "third?"
  dlg 2026-11-28T03:00:00.000Z toolu_3 s2 /b "third?"
} > "$proj/-b/sub/deep/two.jsonl"

data=$tmp/data
mkdir -p "$data"
printf '{"time":"2026-11-28T00:00:00Z","input":{"session_id":"s0","tool_use_id":"toolu_2","tool_response":{}}}\n' > "$data/dialogs.jsonl"
CLAUDE_PLUGIN_DATA=$data
export CLAUDE_PLUGIN_DATA

out=$(sh "$script" "$proj" 2>"$tmp/err"); rc=$?
when "first run exits 0" [ "$rc" -eq 0 ]
when "summary line" [ "$out" = "imported 2 dialogs, 1 already present" ]
f=$data/dialogs.jsonl
when "three lines in the file" [ "$(wc -l < "$f" | tr -d ' ')" = 3 ]
when "existing id kept once, as hook" [ "$(jq -r 'select(.input.tool_use_id=="toolu_2") | .origin // "hook"' "$f")" = hook ]
if jq -e -s '.[1].input.tool_use_id=="toolu_1" and .[2].input.tool_use_id=="toolu_3"' "$f" >/dev/null; then ok "appended in time order"; else bad "appended in time order"; fi
if jq -e -s '.[1] == {time:"2026-11-28T01:00:00.000Z",origin:"import",input:{session_id:"s1",cwd:"/a",tool_name:"AskUserQuestion",tool_use_id:"toolu_1",tool_response:{questions:[{question:"first?",header:"h",options:[{label:"A",description:"d"}],multiSelect:false}],answers:{"first?":"A"}}}}' "$f" >/dev/null; then ok "imported line has its fields"; else bad "imported line has its fields"; fi
if jq -e -s '.[2].input.cwd=="/b" and .[2].input.session_id=="s2"' "$f" >/dev/null; then ok "nested file imported"; else bad "nested file imported"; fi

before=$(cksum < "$f")
out=$(sh "$script" "$proj" 2>/dev/null); rc=$?
when "second run exits 0" [ "$rc" -eq 0 ]
when "second run adds none" [ "$out" = "imported 0 dialogs, 3 already present" ]
when "second run leaves the file" [ "$before" = "$(cksum < "$f")" ]

# Transcripts with no dialog.
empty=$tmp/empty
mkdir -p "$empty/-c"
printf '{"type":"assistant"}\n' > "$empty/-c/x.jsonl"
before=$(cksum < "$f")
if sh "$script" "$empty" 2>"$tmp/err" >/dev/null; then bad "no dialog exits 1"; else ok "no dialog exits 1"; fi
when "no dialog names the internal format" grep -q internal "$tmp/err"
when "no dialog leaves the file" [ "$before" = "$(cksum < "$f")" ]

# No transcripts at all.
mkdir "$tmp/none"
if sh "$script" "$tmp/none" 2>"$tmp/err" >/dev/null; then bad "no transcripts exits 1"; else when "no transcripts exits 1" [ -s "$tmp/err" ]; fi
if sh "$script" "$tmp/missing" 2>/dev/null >/dev/null; then bad "missing folder exits 1"; else ok "missing folder exits 1"; fi

# Unset or empty data folder.
if env -u CLAUDE_PLUGIN_DATA sh "$script" "$proj" 2>/dev/null >/dev/null; then bad "unset data exits 1"; else ok "unset data exits 1"; fi
if CLAUDE_PLUGIN_DATA='' sh "$script" "$proj" 2>/dev/null >/dev/null; then bad "empty data exits 1"; else ok "empty data exits 1"; fi

# A fresh data folder is created.
CLAUDE_PLUGIN_DATA=$tmp/fresh/data sh "$script" "$proj" >/dev/null 2>&1
when "fresh data folder gets 3 lines" [ "$(wc -l < "$tmp/fresh/data/dialogs.jsonl" 2>/dev/null | tr -d ' ')" = 3 ]

exit $failed
