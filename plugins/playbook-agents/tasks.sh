#!/bin/sh
# Keeps the tasks of the works of a project (task-agents-3, -4, -9, -12): adds a
# row to the page docs/wiki/tasks.md, counts the tasks that repeat, fills the
# agent of a task, and checks the page.
# Usage: sh tasks.sh add <task> <work> <steps> [wiki directory]
#        sh tasks.sh count [wiki directory]
#        sh tasks.sh set-agent <task> <agent name|declined> [wiki directory]
#        sh tasks.sh check [wiki directory]
#        sh tasks.sh --help
# The wiki directory is "$CLAUDE_PROJECT_DIR/docs/wiki" when that variable is
# set, else docs/wiki.
# The page has the title "# Tasks" and one table under "## Tasks":
#   | Task | Date | Work | Steps | Agent |
# A task and a work are kebab-case; a date is YYYY-MM-DD; steps are free text in
# one line, with "|" written as "\|"; an agent is empty, kebab-case, or
# "declined".
# - add: appends a row with today's date and an empty agent, and creates the
#   page with its title and header when it is missing. It refuses a newline in
#   any argument and writes `|` of the steps as "\|". It prints one line.
# - count: one line per task held in the threshold of distinct works or more,
#   where no row of the task has an agent or "declined":
#   "ready: <task>: <N> works, last <date>". Nothing when there is no page.
# - set-agent: writes the agent in the agent cell of every row of the task, so a
#   later count does not offer it again (task-agents-11, -12). A task that is
#   not on the page is a bad argument.
# - check: prints "FAIL <file>: <problem>" for each problem and exits 1; else
#   prints one line and exits 0. With no page it says so and exits 0.
# Exit codes: 0 done; 1 check failed; 2 bad usage or bad argument; 4 a write
# failed. The page is replaced whole, by a copy that keeps its mode, so a write
# that fails leaves the page as it was. A cell may hold "|" written as "\|". Not
# read: a table inside a code block. A backslash before a "|" of the steps given
# to add is not told from the escape.

# Distinct works that make a task ready for an agent: task-agents-4. Adjustable.
threshold=3

usage='usage: sh tasks.sh add <task> <work> <steps> [wiki directory]
       sh tasks.sh count [wiki directory]
       sh tasks.sh set-agent <task> <agent name|declined> [wiki directory]
       sh tasks.sh check [wiki directory]'
nl='
'
mode=${1:-}
dirarg=
case $mode in
  --help | -h) printf '%s\n' "$usage"; exit 0 ;;
  add)
    [ $# -ge 4 ] && [ $# -le 5 ] || { printf '%s\n' "$usage" >&2; exit 2; }
    task=$2; work=$3; steps=$4; dirarg=${5:-}
    ;;
  set-agent)
    [ $# -ge 3 ] && [ $# -le 4 ] || { printf '%s\n' "$usage" >&2; exit 2; }
    task=$2; agent=$3; dirarg=${4:-}
    ;;
  count | check)
    [ $# -le 2 ] || { printf '%s\n' "$usage" >&2; exit 2; }
    dirarg=${2:-}
    ;;
  *) printf '%s\n' "$usage" >&2; exit 2 ;;
esac
for arg in "$@"; do
  case $arg in
    *"$nl"*) printf 'tasks.sh: an argument holds a newline\n' >&2; exit 2 ;;
  esac
done
if [ -n "$dirarg" ]; then
  wiki=$dirarg
elif [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  wiki=$CLAUDE_PROJECT_DIR/docs/wiki
else
  wiki=docs/wiki
fi
page=$wiki/tasks.md
header='| Task | Date | Work | Steps | Agent |'

iskebab() { printf '%s\n' "$1" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; }

# replace <file with the new text>: puts it in place of the page, keeping the
# mode of the page; exit 4 when it cannot.
replace() {
  new=$page.tasks.$$
  if [ -e "$page" ]; then
    cp -p "$page" "$new" || { rm -f "$new" "$1"; printf 'tasks.sh: could not write %s\n' "$page" >&2; exit 4; }
  fi
  cat "$1" > "$new" || { rm -f "$new" "$1"; printf 'tasks.sh: could not write %s\n' "$page" >&2; exit 4; }
  mv "$new" "$page" || { rm -f "$new" "$1"; printf 'tasks.sh: could not write %s\n' "$page" >&2; exit 4; }
  rm -f "$1"
}

# run_awk <mode>: reads the page.
run_awk() {
  awk -v mode="$1" -v file="tasks.md" -v threshold="$threshold" -v want="${task:-}" -v agent="${agent:-}" '
  function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t\r]+$/, "", s); return s }
  function fail(msg) { bad = 1; if (mode == "check") print "FAIL " file ": " msg }
  # Splits a table row into cell[1..ncell], with "\|" kept as "|", and into
  # rawc[1..ncell], with it kept as "\|".
  function cells(line,    n, i, ph, c) {
    ph = sprintf("%c", 1)
    gsub(/\\\|/, ph, line)
    n = split(line, raw, "|")
    ncell = 0
    for (i = 2; i <= n; i++) {
      if (i == n && trim(raw[n]) == "") break
      c = trim(raw[i]); ncell++
      rawc[ncell] = c; gsub(ph, "\\|", rawc[ncell])
      cell[ncell] = c; gsub(ph, "|", cell[ncell])
    }
  }
  function joined(    i, s) { s = ""; for (i = 1; i <= ncell; i++) s = s (i > 1 ? "|" : "") cell[i]; return s }
  function isseparator(line) { line = trim(line); return line ~ /^\|[ \t:|-]+$/ && line ~ /-/ }
  function isdate(d,    y, m, dd, mx) {
    if (d !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) return 0
    y = substr(d, 1, 4) + 0; m = substr(d, 6, 2) + 0; dd = substr(d, 9, 2) + 0
    if (m < 1 || m > 12 || dd < 1) return 0
    mx = 31
    if (m == 4 || m == 6 || m == 9 || m == 11) mx = 30
    else if (m == 2) mx = ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28
    return dd <= mx
  }
  function kebab(s) { return s ~ /^[a-z0-9]+(-[a-z0-9]+)*$/ }
  BEGIN { hh = "Task|Date|Work|Steps|Agent"; sec = "" }
  /^```/ { fence = !fence; if (mode == "set") print; next }
  fence { if (mode == "set") print; next }
  /^# / { if (trim(substr($0, 3)) == "Tasks") title = 1; if (mode == "set") print; next }
  /^## / {
    sec = (trim(substr($0, 4)) == "Tasks") ? "T" : ""
    if (sec == "T") { hasT = 1; rowT = 0; doneT = 0 }
    if (mode == "set") print
    next
  }
  /^\|/ {
    if (sec != "T") { if (mode == "set") print; next }
    if (doneT) fail("a table row after the table ended, by a line that is not a row: " $0)
    cells($0)
    rowT++
    if (rowT == 1) { if (joined() != hh) fail("the header row is not: | Task | Date | Work | Steps | Agent |"); if (mode == "set") print; next }
    if (rowT == 2) { if (isseparator($0)) { if (mode == "set") print; next } fail("the second row is not the separator row") }
    if (ncell != 5) { fail("a row has " ncell " cells, not 5: " cell[1]); if (mode == "set") print; next }
    t = cell[1]; d = cell[2]; w = cell[3]; s = cell[4]; a = cell[5]
    if (!kebab(t)) fail("task \"" t "\" is not kebab-case")
    if (!isdate(d)) fail("task \"" t "\" has date \"" d "\", not YYYY-MM-DD")
    if (!kebab(w)) fail("task \"" t "\" has work \"" w "\", not kebab-case")
    if (s == "") fail("task \"" t "\" has no steps")
    if (a != "" && a != "declined" && !kebab(a)) fail("task \"" t "\" has agent \"" a "\", not empty, kebab-case, or declined")
    if (mode == "set" && t == want) {
      print "| " rawc[1] " | " rawc[2] " | " rawc[3] " | " rawc[4] " | " agent " |"
      hit++
    } else if (mode == "set") print
    if (isdate(d) && d > last[t]) last[t] = d
    if (!(t in seen)) { order[++nt] = t; seen[t] = 1 }
    if (!((t SUBSEP w) in wk)) { wk[t SUBSEP w] = 1; nw[t]++ }
    if (a != "") has[t] = 1
    next
  }
  { if (sec == "T" && rowT > 0) doneT = 1; if (mode == "set") print }
  END {
    if (mode == "check") {
      if (!title) fail("missing the heading \"# Tasks\"")
      if (!hasT) fail("missing the heading \"## Tasks\"")
      else if (rowT == 0) fail("Tasks has no table")
      exit bad
    }
    if (mode == "count") {
      for (i = 1; i <= nt; i++) {
        t = order[i]
        if (nw[t] >= threshold && !(t in has)) printf "ready: %s: %d works, last %s\n", t, nw[t], last[t]
      }
      exit 0
    }
    if (mode == "set" && !hit) exit 3
  }' "$page"
}

case $mode in
  add)
    iskebab "$task" || { printf 'tasks.sh: the task "%s" is not kebab-case\n' "$task" >&2; exit 2; }
    iskebab "$work" || { printf 'tasks.sh: the work "%s" is not kebab-case\n' "$work" >&2; exit 2; }
    steps=$(printf '%s' "$steps" | sed 's/|/\\|/g; s/^[ \t]*//; s/[ \t\r]*$//')
    [ -n "$steps" ] || { printf 'tasks.sh: the steps are empty\n' >&2; exit 2; }
    mkdir -p "$wiki" || { printf 'tasks.sh: could not make %s\n' "$wiki" >&2; exit 4; }
    today=$(date +%Y-%m-%d)
    work_file=$(mktemp "${TMPDIR:-/tmp}/tasks.XXXXXX") || { printf 'tasks.sh: could not make a temporary file\n' >&2; exit 4; }
    if [ -f "$page" ]; then
      awk '{ print }' "$page" > "$work_file"
    else
      printf '# Tasks\n\n## Tasks\n\n%s\n|------|------|------|-------|-------|\n' "$header" > "$work_file"
    fi
    printf '| %s | %s | %s | %s |  |\n' "$task" "$today" "$work" "$steps" >> "$work_file" || { rm -f "$work_file"; exit 4; }
    replace "$work_file"
    printf 'added the task %s of the work %s to %s\n' "$task" "$work" "$page"
    ;;
  count)
    [ -f "$page" ] || exit 0
    run_awk count
    ;;
  set-agent)
    iskebab "$task" || { printf 'tasks.sh: the task "%s" is not kebab-case\n' "$task" >&2; exit 2; }
    if [ "$agent" != declined ]; then
      iskebab "$agent" || { printf 'tasks.sh: the agent "%s" is not kebab-case or declined\n' "$agent" >&2; exit 2; }
    fi
    [ -f "$page" ] || { printf 'tasks.sh: there is no page %s\n' "$page" >&2; exit 2; }
    work_file=$(mktemp "${TMPDIR:-/tmp}/tasks.XXXXXX") || { printf 'tasks.sh: could not make a temporary file\n' >&2; exit 4; }
    run_awk set > "$work_file"; code=$?
    if [ "$code" -ne 0 ]; then
      rm -f "$work_file"
      [ "$code" -eq 3 ] && printf 'tasks.sh: the task "%s" is not on %s\n' "$task" "$page" >&2
      exit 2
    fi
    replace "$work_file"
    printf 'set the agent of the task %s to %s in %s\n' "$task" "$agent" "$page"
    ;;
  check)
    if [ ! -f "$page" ]; then
      printf 'no tasks page at %s; nothing to check\n' "$page"
      exit 0
    fi
    out=$(run_awk check)
    code=$?
    if [ "$code" -ne 0 ]; then
      printf '%s\n' "$out"
      exit 1
    fi
    printf 'tasks check passed: %s\n' "$page"
    ;;
esac
