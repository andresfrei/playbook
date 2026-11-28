#!/bin/sh
# shellcheck disable=SC2016  # the sh -c bodies expand in the child shell
# Tests of plugins/playbook/scripts/dialog-table.sh. Run from the repository root.
script=$PWD/plugins/playbook/scripts/dialog-table.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0

ok() { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; failed=1; }
# when NAME CMD...: ok when the command succeeds.
when() { n=$1; shift; if "$@"; then ok "$n"; else bad "$n"; fi; }
# has NAME TEXT: ok when the output holds the line TEXT exactly.
has() { if printf '%s\n' "$out" | grep -qxF -- "$2"; then ok "$1"; else bad "$1"; fi; }
hasnt() { if printf '%s\n' "$out" | grep -qF -- "$2"; then bad "$1"; else ok "$1"; fi; }
# q QUESTION HEADER OPT1 OPT2 [MULTI]: a question object.
q() {
  printf '{"question":"%s","header":"%s","options":[{"label":"%s","description":"d"},{"label":"%s","description":"d"}],"multiSelect":%s}' "$1" "$2" "$3" "$4" "${5:-false}"
}
# line TIME ORIGIN CWD ID QUESTIONS ANSWERS: ORIGIN may be empty (the hook).
line() {
  o=
  [ -n "$2" ] && o="\"origin\":\"$2\","
  printf '{"time":"%s",%s"input":{"session_id":"s","cwd":"%s","tool_name":"AskUserQuestion","tool_use_id":"%s","tool_response":{"questions":[%s],"answers":{%s}}}}\n' "$1" "$o" "$3" "$4" "$5" "$6"
}

data=$tmp/data
mkdir -p "$data"
f=$data/dialogs.jsonl
{
  # /p/b: hook lines. Session took first; Session departed with own words.
  line 2026-11-01T01:00:00Z "" /p/b t1 "$(q 'Go on?' Session Yes No)" '"Go on?":"Yes"'
  line 2026-11-01T02:00:00Z "" /p/b t2 "$(q 'Clear now?' Session Yes No)" '"Clear now?":"Do it later"'
  # Multi-question dialog: Scope departs to the second option, Product takes first.
  line 2026-11-01T03:00:00Z "" /p/b/sub t3 "$(q 'Which scope?' Scope Small Big),$(q 'What for?' Product Users Team)" '"Which scope?":"Big","What for?":"Users"'
  # Untyped headers.
  line 2026-11-01T04:00:00Z "" /p/b t4 "$(q 'Version?' Siguiente 0.1 0.2)" '"Version?":"0.2"'
  line 2026-11-01T05:00:00Z "" /p/b t5 "$(q 'Other?' Seguir A B)" '"Other?":"A"'
  # Import lines in the sibling-prefix project /p/bc and in /p/b.
  line 2026-10-31T01:00:00Z import /p/bc t6 "$(q 'Go on?' Session Yes No)" '"Go on?":"No"'
  line 2026-10-31T02:00:00Z import /p/bc t7 "$(q 'Pick' Delivery Merge Wait)" '"Pick":"Merge"'
  line 2026-10-30T01:00:00Z import /p/b t8 "$(q 'Pick many' Setup X Y true)" '"Pick many":"X, Y"'
  printf 'not json {\n'
  printf '{"time":"2026-11-01T06:00:00Z","input":{"cwd":"/p/b","tool_use_id":"t9","tool_response":{"other":1}}}\n'
  printf '{"time":"2026-11-01T07:00:00Z","input":"x"}\n'
} > "$f"
CLAUDE_PLUGIN_DATA=$data
export CLAUDE_PLUGIN_DATA

out=$(sh "$script" /p/b 2>"$tmp/err"); rc=$?
when "exits 0" [ "$rc" -eq 0 ]
when "no stderr" [ ! -s "$tmp/err" ]

# Counts, whole file: Session 3 (2 first of... Yes, own, No) -> 1/3 = 33%, 2 projects.
has "Session row" "| Session | 3 | 33% | 2 |"
has "Delivery row" "| Delivery | 1 | 100% | 1 |"
has "Setup row" "| Setup | 1 | 0% | 1 |"
has "Scope row" "| Scope | 1 | 0% | 1 |"
has "Product row" "| Product | 1 | 100% | 1 |"
has "untyped row" "| untyped | 2 | 50% | 1 |"
hasnt "no row for an empty type" "| Accept |"
hasnt "invalid and shapeless lines add no row" "| Load |"

# Own words in /p/b only: "Do it later". The multiSelect X, Y is made of labels.
has "own-words count of the project" "Own-words answers in /p/b: 1"

# Departures of /p/b only (not /p/bc), in time order.
dep=$(printf '%s\n' "$out" | sed -n '/^Departures in/,/^Untyped questions/p')
when "departure with question" sh -c 'printf "%s\n" "$1" | grep -qF -- "[Session] Clear now?"' _ "$dep"
when "departure with options" sh -c 'printf "%s\n" "$1" | grep -qxF -- "  options: Yes (recommended) / No"' _ "$dep"
when "departure with answer" sh -c 'printf "%s\n" "$1" | grep -qxF -- "  answer: Do it later"' _ "$dep"
when "departure of the multi-question dialog" sh -c 'printf "%s\n" "$1" | grep -qF -- "[Scope] Which scope?"' _ "$dep"
when "departure of a multiSelect with labels" sh -c 'printf "%s\n" "$1" | grep -qF -- "[Setup] Pick many"' _ "$dep"
when "first-option answers are no departure" sh -c '! printf "%s\n" "$1" | grep -qF -- "[Product]"' _ "$dep"
when "other project is no departure" sh -c '! printf "%s\n" "$1" | grep -qF -- "[Session] Go on?"' _ "$dep"
when "departures in time order" sh -c 'a=$(printf "%s\n" "$1" | grep -n "Pick many" | cut -d: -f1); b=$(printf "%s\n" "$1" | grep -n "Clear now" | cut -d: -f1); [ "$a" -lt "$b" ]' _ "$dep"

# Untyped block: both untyped questions, every project, as JSON lines.
when "untyped block has the version question" sh -c 'printf "%s\n" "$1" | grep -qF -- "{\"id\":\"t4\",\"question\":\"Version?\",\"header\":\"Siguiente\",\"options\":[\"0.1\",\"0.2\"],\"answer\":\"0.2\"}"' _ "$out"
when "untyped block has the other question" sh -c 'printf "%s\n" "$1" | grep -qF -- "\"id\":\"t5\""' _ "$out"

# The sibling project, run on its own.
out2=$(sh "$script" /p/bc 2>/dev/null)
when "sibling lists its own departure" sh -c 'printf "%s\n" "$1" | grep -qF -- "[Session] Go on?"' _ "$out2"
when "sibling does not list /p/b departures" sh -c '! printf "%s\n" "$1" | grep -qF -- "Clear now?"' _ "$out2"
when "trailing slash on PROJECT_DIR" sh -c 'printf "%s\n" "$1" | grep -qxF -- "Own-words answers in /p/b: 1"' _ "$(sh "$script" /p/b/ 2>/dev/null | sed 's#/p/b/:#/p/b:#')"

# TYPES_FILE moves one question out of untyped.
types=$tmp/types.jsonl
{
  printf '{"id":"t4","question":"Version?","type":"Delivery"}\n'
  printf 'bad line\n'
  printf '{"id":"t5","question":"Other?","type":"Nonsense"}\n'
} > "$types"
out=$(sh "$script" /p/b "$types" 2>/dev/null)
has "typed question joins Delivery" "| Delivery | 2 | 50% | 2 |"
has "untyped drops to one" "| untyped | 1 | 100% | 1 |"
hasnt "typed question leaves the untyped block" '"id":"t4"'
when "a word outside the list is ignored" sh -c 'printf "%s\n" "$1" | grep -qF -- "\"id\":\"t5\""' _ "$out"
when "typed departure is listed with its type" sh -c 'printf "%s\n" "$1" | grep -qF -- "[Delivery] Version?"' _ "$out"

# No untyped question: no block.
g=$tmp/g/dialogs.jsonl
mkdir -p "$tmp/g"
line 2026-11-01T01:00:00Z "" /p/b a1 "$(q 'Go on?' Session Yes No)" '"Go on?":"Yes"' > "$g"
out=$(CLAUDE_PLUGIN_DATA=$tmp/g sh "$script" /p/b 2>/dev/null)
hasnt "no untyped block when none" "Untyped questions"

# Errors.
if sh "$script" 2>"$tmp/err" >/dev/null; then bad "no PROJECT_DIR exits 1"; else when "no PROJECT_DIR exits 1" [ -s "$tmp/err" ]; fi
if env -u CLAUDE_PLUGIN_DATA sh "$script" /p/b 2>"$tmp/err" >/dev/null; then bad "unset data exits 1"; else when "unset data exits 1" [ -s "$tmp/err" ]; fi
mkdir "$tmp/empty"
if CLAUDE_PLUGIN_DATA=$tmp/empty sh "$script" /p/b 2>"$tmp/err" >/dev/null; then bad "no file exits 1"; else when "no file exits 1" [ -s "$tmp/err" ]; fi
if sh "$script" /p/b "$tmp/missing" 2>/dev/null >/dev/null; then bad "missing TYPES_FILE exits 1"; else ok "missing TYPES_FILE exits 1"; fi
mkdir "$tmp/nojq"
ln -s "$(command -v sh)" "$tmp/nojq/sh"
if PATH=$tmp/nojq sh "$script" /p/b 2>"$tmp/err" >/dev/null; then bad "no jq exits 1"; else when "no jq exits 1" grep -q jq "$tmp/err"; fi

exit $failed
