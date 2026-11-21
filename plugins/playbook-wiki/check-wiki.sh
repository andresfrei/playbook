#!/bin/sh
# Checks a project's wiki against the format in format.md, next to this file.
# Usage: sh check-wiki.sh [wiki directory]    (default: docs/wiki)
#        sh check-wiki.sh --column [wiki directory]
#        sh check-wiki.sh --decisions [wiki directory]
#        sh check-wiki.sh --decisions --in-force [shared page] [wiki directory]
#        sh check-wiki.sh --delegations [wiki directory]
#        sh check-wiki.sh --format
# It fails at once, with one line and without running the other rules, when
# the marker $wiki/.format is missing, is not a number, or is below the format
# the playbook is at (6). A marker above it passes. It then fails when:
# - $wiki/decisions.md exists: the decisions from before works belong in
#   works/history/decisions.md, which /playbook-wiki:migrate makes;
# - a relative link in a page does not resolve to a file or a directory;
# - a path that the wiki names as code does not exist in the project: a path
#   in the column "Code it governs" of a table of README.md or of the README.md
#   of a work, or in the first column of a table under a heading "Code on the
#   old definition" of any page.
# A path is the text of a code span, and it is read from the project's root,
# which is two directories above the wiki, by the path the wiki was given
# with.
# When the wiki has a works/ folder, each folder works/<name>/ also fails when:
# - <name> is not lowercase letters, digits, and single hyphens;
# - it has no README.md, or its "Where work stands" has more than 250 words
#   (a missing section is not a failure). The folder works/history, which
#   holds the decisions from before works, needs no README.md;
# - the first cell of a data row of a table of decisions.md, questions.md, or
#   plan.md is not an identifier of the work: <name>-<n> in decisions.md,
#   <name>-Q<n> in questions.md, <name>-U<n> in plan.md, n a positive integer
#   without a leading zero. In plan.md only a cell that ends in -U and a
#   number is checked. In works/history/decisions.md the identifier is D<n> or
#   TD<n>. Within one table an identifier is not repeated;
# - a decision in decisions.md has more than 60 words of text (not in the
#   history, whose rows are kept as they were written), or a row
#   that does not have exactly nine columns: id, date, decision, who decided,
#   their words, shared page, replaces, kind, answer;
# - the shared page (sixth column) is neither "none" nor code spans of paths,
#   relative to the wiki, of pages that exist, are not under works/, and cite
#   the identifier as a whole word;
# - Replaces (seventh column) is not empty and is not a list, separated by
#   ", ", of identifiers of decisions that exist in some works/*/decisions.md,
#   history included, or it names the decision of its own row;
# - Kind (eighth column) is not empty and is not one of definition,
#   technology, plan, open-work, close-stage, close-work, commit, merge-push,
#   version, consolidate, other; or Answer (ninth column) is not empty and is
#   not one of as recommended, changed, rejected, delegated. Replaces, Kind,
#   and Answer may end in exactly one space and "(estimated)", which migrate
#   writes; what is left must still be valid, so "(estimated)" alone or
#   "plan(estimated)" fails. An empty cell passes.
# The README.md of the project keeps no state: it fails when it has no line
# "Project owner: <name>", or a heading "Where work stands" or a table whose
# first header cell is "Stage".
# With --format it prints the format the playbook is at, and exits 0.
# With --column it prints nothing, and exits 0 when a table of README.md has
# the column "Code it governs" and 1 when none has.
# With --decisions it prints each decision of each work, one per line, as
# "<date> <identifier> <decision>", ordered by date, then work, then number,
# and checks nothing. A wiki without works prints nothing.
# With --decisions --in-force it prints only the decisions in force, as
# "<date> <identifier> <shared page> <decision>": those whose shared page is
# not "none" and that no row of any work names in Replaces. A shared page
# given as an argument keeps only the decisions that name that page. A single
# argument is a page when it ends in .md, and the wiki directory otherwise; with
# two arguments the first is the page, which may be "" for none. It checks nothing.
# With --delegations it reads the marker of no wiki and checks nothing. For
# each Kind it counts the rows of every work's decisions.md whose Answer is not
# empty, with " (estimated)" taken off and the Answer "delegated" left out,
# since the owner was not asked. It prints one line for each Kind that has at
# least 10 such rows, at least 80% "as recommended", and no "rejected", such
# as "close-stage: 14 answers, 92% as recommended, 0 rejected", in the order
# of the list of kinds. It prints nothing when none qualifies, and exits 0.
# Not checked: reference-style links ([text][id]); a link whose target holds a
# space, a parenthesis, or a percent-encoded character; and a table cell or a
# code span that holds the character "|".
# Exits 0 when every rule holds, 1 otherwise.
set -u

# The format of a wiki the playbook is at, held here and nowhere else. Raise it
# only together with the rules of format.md.
present_format=6

mode=check
in_force=
filter=
case ${1:-} in
  --column) mode=column; shift ;;
  --decisions)
    mode=decisions; shift
    if [ "${1:-}" = --in-force ]; then
      in_force=1; shift
      case ${1:-} in
        *.md) filter=$1; shift ;;
        *) if [ $# -ge 2 ]; then filter=$1; shift; fi ;;
      esac
    fi ;;
  --delegations) mode=delegations; shift ;;
  --format) printf '%s\n' "$present_format"; exit 0 ;;
esac
wiki=${1:-docs/wiki}
wiki=${wiki%/}
max_state_words=250
max_decision_words=60
tab=$(printf '\t')

if [ "$mode" != decisions ] && [ "$mode" != delegations ] && [ ! -f "$wiki/README.md" ]; then
  printf 'FAIL %s has no README.md\n' "$wiki"
  exit 1
fi

# The gate: the marker must be a number, and not below the playbook's format.
# A value that is empty, not digits, or longer than nine digits is no number.
if [ "$mode" = check ]; then
  marker_value=
  if [ -f "$wiki/.format" ]; then
    marker_value=$(head -n 1 "$wiki/.format" | tr -d ' \t\r')
    case $marker_value in
      ''|*[!0-9]*|??????????*) marker_value= ;;
    esac
  fi
  if [ -z "$marker_value" ] || [ "$marker_value" -lt "$present_format" ]; then
    printf 'FAIL %s is at wiki format %s, and the playbook is at %s. Bring it there with /playbook-wiki:migrate.\n' \
      "$wiki" "${marker_value:-none}" "$present_format"
    exit 1
  fi
fi

# The project's root. The cd follows the path as it was given, so a wiki
# directory that is a link still leads to the project that links to it.
project=$(CDPATH='' cd -- "$wiki/../.." 2>/dev/null && pwd) || project="$wiki/../.."

failures=0

# The start of every awk program: it drops a carriage return at the end of a
# line and sets "fenced" inside a fenced code block, which ends only at the
# marker that opened it.
# shellcheck disable=SC2016
fences='{ sub(/\r$/, "") }
/^[ \t]*(```|~~~)/ {
  mark = ($0 ~ /^[ \t]*```/) ? "`" : "~"
  if (!fenced) { fenced = 1; opened = mark } else if (mark == opened) fenced = 0
  next
}'

# work_table <file> <work> <kind> <label> <what>
# Reads the tables of a work's decisions.md (kind d), questions.md (kind q),
# or plan.md (kind p). A data row is a table line after the separator line of
# its table. With <what> "check" it prints a line that starts with FAIL for
# each rule that a row breaks, and for each path that a decision names as its
# shared page a line "SHARED<tab><identifier><tab><path>", which the caller
# checks, and for each identifier that a decision names in Replaces a line
# "REPLACES<tab><identifier><tab><replaced>", which the caller checks. With
# <what> "list" it prints one line for each decision: date, work, number,
# identifier, text, shared pages (paths joined by ", ", or none), and the
# identifiers it replaces (separated by a space), separated by tabs. With <what>
# "answers" it prints, for each decision whose Kind is not empty, a line with
# the Kind and the Answer, separated by a tab, without " (estimated)".
# In the work "history" an identifier is D<n> or TD<n>.
work_table() {
  awk -v work="$2" -v kind="$3" -v label="$4" -v what="$5" -v max="$max_decision_words" "$fences"'
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function fail(msg) { printf "FAIL %s: %s\n", label, msg }
    BEGIN {
      hist = (work == "history")
      n = split("definition technology plan open-work close-stage close-work commit merge-push version consolidate other", list, " ")
      for (i = 1; i <= n; i++) kinds[list[i]] = 1
      n = split("as recommended|changed|rejected|delegated", list, "|")
      for (i = 1; i <= n; i++) answers[list[i]] = 1
    }
    fenced { next }
    /^[ \t]*\|/ {
      line = $0
      sub(/^[ \t]*\|/, "", line)
      sub(/\|[ \t]*$/, "", line)
      cells = split(line, c, "|")
      if (!sep) {
        if (line ~ /^[ \t]*:?-+:?[ \t]*(\||$)/) { sep = 1; delete seen }
        next
      }
      id = trim(c[1])
      # plan.md may hold other tables, of dates or names: only a cell that
      # ends in -U and a number is read as a unit.
      if (kind == "p" && id !~ /-U[0-9]+$/) next
      prefix = ""; letter = ""; num = ""
      if (hist) {
        if (id ~ /^(D|TD)[1-9][0-9]*$/) { prefix = work; num = id; sub(/^(TD|D)/, "", num) }
        valid = (num != "")
        expected = "D<number> or TD<number>"
      } else {
        if (match(id, /-[^-]*$/)) {
          prefix = substr(id, 1, RSTART - 1)
          num = substr(id, RSTART + 1)
          if (num ~ /^[A-Za-z][0-9]+$/) { letter = substr(num, 1, 1); num = substr(num, 2) }
        }
        want = (kind == "q") ? "Q" : (kind == "p") ? "U" : ""
        valid = (prefix ~ /^[a-z0-9]+(-[a-z0-9]+)*$/ && num ~ /^[1-9][0-9]*$/)
        expected = work "-" want "<number>"
      }
      if (what == "answers") {
        if (valid && prefix == work && letter == "" && cells == 9) {
          k = trim(c[8]); a = trim(c[9])
          sub(/ \(estimated\)$/, "", k)
          sub(/ \(estimated\)$/, "", a)
          if (k != "") printf "%s\t%s\n", k, a
        }
        next
      }
      if (what == "list") {
        if (valid && prefix == work && letter == "")
        {
          text = trim(c[3])
          gsub(/\t/, " ", text)
          pages = ""
          rest = trim(c[6])
          while (match(rest, /`[^`]+`/)) {
            path = substr(rest, RSTART + 1, RLENGTH - 2)
            rest = substr(rest, RSTART + RLENGTH)
            while (path ~ /^\.\//) path = substr(path, 3)
            pages = pages (pages == "" ? "" : ", ") path
          }
          if (pages == "") pages = "none"
          repl = ""
          if (cells == 9) {
            repl = trim(c[7]); sub(/ \(estimated\)$/, "", repl)
            gsub(/,[ \t]*/, " ", repl)
          }
          printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", trim(c[2]), work, num, id, text, pages, repl
        }
        next
      }
      if (!valid) {
        fail(((id == "") ? "a row with an empty first cell" : id " is not an identifier") \
          ", expected " expected ", a number from 1 without a leading zero")
        next
      }
      ok = 1
      if (prefix != work) { fail(id " carries the work " prefix ", but the folder is " work); ok = 0 }
      else if (letter != want) { fail(id " has the wrong letter, expected " expected); ok = 0 }
      if (id in seen) { fail(id " is repeated"); ok = 0 }
      seen[id] = 1
      if (!ok || kind != "d") next
      words = split(c[3], word, " ")
      if (words > max && !hist) fail(sprintf("the decision of %s has %d words, limit %d", id, words, max))
      if (cells != 9) { fail("the row of " id " has " cells " columns, not the nine of the format: id, date, decision, who, words, shared page, replaces, kind, answer"); next }
      r = trim(c[7]); sub(/ \(estimated\)$/, "", r)
      if (r != "") {
        m = split(r, parts, ", ")
        for (i = 1; i <= m; i++) {
          if (parts[i] == id) fail("the row of " id " replaces itself")
          else printf "REPLACES\t%s\t%s\n", id, parts[i]
        }
      }
      k = trim(c[8]); sub(/ \(estimated\)$/, "", k)
      if (k != "" && !(k in kinds))
        fail("the kind of " id " is " trim(c[8]) ", which is not in the list of kinds")
      a = trim(c[9]); sub(/ \(estimated\)$/, "", a)
      if (a != "" && !(a in answers))
        fail("the answer of " id " is " trim(c[9]) ", which is not in the list of answers")
      shared = trim(c[6])
      if (tolower(shared) == "none") next
      found = 0
      while (match(shared, /`[^`]+`/)) {
        printf "SHARED\t%s\t%s\n", id, substr(shared, RSTART + 1, RLENGTH - 2)
        shared = substr(shared, RSTART + RLENGTH)
        found = 1
      }
      if (!found) fail("the shared page of " id " is neither none nor a path in a code span")
      next
    }
    { sep = 0; delete seen }' "$1"
}

# The folders of $wiki/works, hidden ones included.
work_dirs() {
  for dir in "$wiki"/works/*/ "$wiki"/works/.[!.]*/; do
    [ -d "$dir" ] && printf '%s\n' "${dir%/}"
  done
}

if [ "$mode" = decisions ]; then
  if [ ! -d "$wiki" ]; then
    printf 'FAIL %s is not a directory\n' "$wiki"
    exit 1
  fi
  [ -d "$wiki/works" ] || exit 0
  work_dirs | while IFS= read -r dir; do
    [ -f "$dir/decisions.md" ] &&
      work_table "$dir/decisions.md" "$(basename "$dir")" d "" list
  done | LC_ALL=C sort -t "$tab" -k1,1 -k2,2 -k3,3n |
    awk -F '\t' -v in_force="$in_force" -v filter="$filter" '
      !in_force { printf "%s %s %s\n", $1, $4, $5; next }
      {
        n++; date[n] = $1; ident[n] = $4; text[n] = $5; page[n] = $6
        m = split($7, r, " ")
        for (j = 1; j <= m; j++) replaced[r[j]] = 1
      }
      END {
        for (i = 1; i <= n; i++) {
          if (page[i] == "none" || (ident[i] in replaced)) continue
          if (filter != "") {
            hit = 0
            m = split(page[i], p, ", ")
            for (j = 1; j <= m; j++) if (p[j] == filter) hit = 1
            if (!hit) continue
          }
          printf "%s %s %s %s\n", date[i], ident[i], page[i], text[i]
        }
      }'
  exit 0
fi

if [ "$mode" = delegations ]; then
  if [ ! -d "$wiki" ]; then
    printf 'FAIL %s is not a directory\n' "$wiki"
    exit 1
  fi
  [ -d "$wiki/works" ] || exit 0
  work_dirs | while IFS= read -r dir; do
    [ -f "$dir/decisions.md" ] &&
      work_table "$dir/decisions.md" "$(basename "$dir")" d "" answers
  done | awk -F '\t' '
    BEGIN {
      n = split("definition technology plan open-work close-stage close-work commit merge-push version consolidate other", order, " ")
    }
    $2 != "" && $2 != "delegated" {
      total[$1]++
      if ($2 == "as recommended") yes[$1]++
      if ($2 == "rejected") no[$1]++
    }
    END {
      for (i = 1; i <= n; i++) {
        k = order[i]
        if (total[k] >= 10 && yes[k] * 100 >= 80 * total[k] && no[k] == 0)
          printf "%s: %d answers, %d%% as recommended, %d rejected\n", k, total[k], int(yes[k] * 100 / total[k]), no[k]
      }
    }'
  exit 0
fi

# code_paths <page> <mode>
# Prints each path that a page names as code, one per line: the code spans of
# the first column of a table under a heading "Code on the old definition"
# and, with the mode "readme", of the column "Code it governs" of a table.
# With the mode "column" it prints nothing, and fails when no table of the
# page has that column. It skips fenced code blocks.
code_paths() {
  awk -v mode="$2" "$fences"'
    function spans(text) {
      if (mode == "column") return
      while (match(text, /`[^`]+`/)) {
        print substr(text, RSTART + 1, RLENGTH - 2)
        text = substr(text, RSTART + RLENGTH)
      }
    }
    fenced { next }
    /^#+[ \t]/ {
      match($0, /^#+/)
      if ($0 ~ /^#+[ \t]+Code on the old definition/) { old = 1; level = RLENGTH; next }
      if (old && RLENGTH <= level) old = 0
    }
    /^[ \t]*\|/ {
      cells = split($0, cell, "|")
      if (old) spans(cell[2])
      if (mode != "page") {
        if (column) spans(cell[column])
        else for (i = 2; i <= cells; i++) {
          title = cell[i]
          gsub(/^[ \t]+|[ \t]+$/, "", title)
          if (title == "Code it governs") { column = i; found = 1 }
        }
      }
      next
    }
    { column = 0 }
    END { if (mode == "column" && !found) exit 1 }' "$1"
}

if [ "$mode" = column ]; then
  code_paths "$wiki/README.md" column
  exit $?
fi

# state_count <page>
# The words under the heading "Where work stands", whatever its level and
# whatever follows the title, up to the next heading of its level or above.
# Prints "none" when the page has no such heading.
state_count() {
  awk "$fences"'
    !fenced && /^#+[ \t]/ {
      match($0, /^#+/)
      if ($0 ~ /^#+[ \t]+Where work stands/) { inside = 1; found = 1; level = RLENGTH; next }
      if (inside && RLENGTH <= level) inside = 0
    }
    inside { words += NF }
    END { if (found) print words + 0; else print "none" }' "$1"
}

# The project's README.md. It prints a line that starts with FAIL for each rule
# that it breaks: no line "Project owner: <name>"; a heading "Where work
# stands" or a table whose first header cell is "Stage". It skips fenced code
# blocks.
readme_checks() {
  awk -v label="$wiki/README.md" "$fences"'
    function fail(msg) { printf "FAIL %s %s\n", label, msg }
    fenced { next }
    /^#+[ \t]/ {
      table = 0
      if ($0 ~ /^#+[ \t]+Where work stands/)
        fail("has the heading \"Where work stands\"; the state belongs to a work")
      next
    }
    /^Project owner:[ \t]+[^ \t]/ { owner = 1 }
    /^[ \t]*\|/ {
      line = $0
      sub(/^[ \t]*\|/, "", line)
      if (!table) {
        table = 1
        split(line, c, "|")
        first = c[1]
        gsub(/^[ \t]+|[ \t]+$/, "", first)
      } else if (table == 1) {
        table = 2
        if (first == "Stage" && line ~ /^[ \t]*:?-+:?[ \t]*(\||$)/)
          fail("has a stage table; a stage table belongs to a work")
      }
      next
    }
    { table = 0 }
    END { if (!owner) fail("has no line \"Project owner: <name>\"") }' "$wiki/README.md"
}

if [ -e "$wiki/decisions.md" ]; then
  printf 'FAIL %s/decisions.md exists at the top of the wiki: move it to works/history/decisions.md: run /playbook-wiki:migrate\n' "$wiki"
  failures=$((failures + 1))
fi

readme_bad=$(readme_checks)
if [ -n "$readme_bad" ]; then
  printf '%s\n' "$readme_bad"
  failures=$((failures + $(printf '%s\n' "$readme_bad" | wc -l | tr -d ' ')))
fi

# Prints the target of each relative link of a page, one per line. It skips
# fenced code blocks, code spans, addresses with a scheme, anchors of the same
# page, and absolute paths, and drops the anchor and the title of a target.
link_targets() {
  awk "$fences"'
    fenced { next }
    {
      line = $0
      gsub(/`[^`]*`/, "", line)
      while (match(line, /\]\([^)]*\)/)) {
        target = substr(line, RSTART + 2, RLENGTH - 3)
        line = substr(line, RSTART + RLENGTH)
        sub(/^[ \t]+/, "", target)
        sub(/[ \t].*$/, "", target)
        sub(/#.*$/, "", target)
        if (target == "" || target ~ /^\// || target ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) continue
        print target
      }
    }' "$1"
}

# The slash makes find enter a wiki directory that is a link.
broken=$(
  find "$wiki/" -name '*.md' | sort | while IFS= read -r page; do
    link_targets "$page" | while IFS= read -r target; do
      [ -e "$(dirname "$page")/$target" ] ||
        printf 'FAIL %s links to %s, which does not exist\n' "$page" "$target"
    done
  done
)
if [ -n "$broken" ]; then
  printf '%s\n' "$broken"
  failures=$((failures + $(printf '%s\n' "$broken" | wc -l | tr -d ' ')))
fi

# The column is read in the entry point only; the lists of old code, in
# every page.
missing=$(
  find "$wiki/" -name '*.md' | sort | while IFS= read -r page; do
    # BSD find prints "$wiki//page", GNU find "$wiki/page".
    inside=${page#"$wiki"/}
    inside=${inside#/}
    case $inside in
      README.md) pages=readme ;;
      works/*/*/README.md) pages=page ;;
      works/*/README.md) pages=readme ;;
      *) pages=page ;;
    esac
    code_paths "$page" "$pages" | while IFS= read -r path; do
      [ -e "$project/$path" ] ||
        printf 'FAIL %s names the path %s, which does not exist in the project\n' "$page" "$path"
    done
  done
)
if [ -n "$missing" ]; then
  printf '%s\n' "$missing"
  failures=$((failures + $(printf '%s\n' "$missing" | wc -l | tr -d ' ')))
fi

# The folders of $wiki/works. It prints the failures, one per line.
work_checks() {
  work_dirs | while IFS= read -r dir; do
    name=$(basename "$dir")
    rel="works/$name"
    if ! printf '%s\n' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      printf 'FAIL %s: the name of the folder is not lowercase letters, digits, and single hyphens\n' "$rel"
      continue
    fi
    if [ "$name" = history ]; then
      :
    elif [ ! -f "$dir/README.md" ]; then
      printf 'FAIL %s has no README.md\n' "$rel"
    else
      words=$(state_count "$dir/README.md")
      if [ "$words" != none ] && [ "$words" -gt "$max_state_words" ]; then
        printf 'FAIL %s/README.md: "Where work stands" has %s words, limit %s\n' "$rel" "$words" "$max_state_words"
      fi
    fi
    for entry in decisions:d questions:q plan:p; do
      file=${entry%:*}.md
      [ -f "$dir/$file" ] || continue
      work_table "$dir/$file" "$name" "${entry#*:}" "$rel/$file" check |
        while IFS=$tab read -r tag id path; do
          case $tag in
            SHARED) shared_page "$rel/$file" "$id" "$path" ;;
            REPLACES)
              printf '%s\n' "$known_ids" | grep -Fxq -- "$path" ||
                printf 'FAIL %s: the row of %s replaces %s, which is not a decision of any work\n' "$rel/$file" "$id" "$path" ;;
            *) printf '%s\n' "$tag${id:+$tab$id}${path:+$tab$path}" ;;
          esac
        done
    done
  done
}

# shared_page <file> <identifier> <path>
# Prints a failure when the shared page that a decision names is not a page
# outside works/ that cites the identifier.
shared_page() {
  page=$3
  while :; do case $page in ./*) page=${page#./} ;; *) break ;; esac; done
  case $page in
    works/*) printf 'FAIL %s: the shared page %s of %s is under works/, and must be a shared page\n' "$1" "$3" "$2" ;;
    *)
      if [ ! -f "$wiki/$page" ]; then
        printf 'FAIL %s: the shared page %s of %s is not a file in the wiki\n' "$1" "$3" "$2"
      elif ! grep -Eq "(^|[^A-Za-z0-9_-])$2([^A-Za-z0-9_-]|\$)" "$wiki/$page"; then
        printf 'FAIL %s: the shared page %s does not cite %s\n' "$1" "$3" "$2"
      fi ;;
  esac
}

# The identifiers of every decision of every work, history included.
all_ids() {
  work_dirs | while IFS= read -r dir; do
    [ -f "$dir/decisions.md" ] &&
      work_table "$dir/decisions.md" "$(basename "$dir")" d "" list | cut -f 4
  done
}

if [ -d "$wiki/works" ]; then
  known_ids=$(all_ids)
  bad=$(work_checks)
  if [ -n "$bad" ]; then
    printf '%s\n' "$bad"
    failures=$((failures + $(printf '%s\n' "$bad" | wc -l | tr -d ' ')))
  fi
fi

if [ "$failures" -gt 0 ]; then
  printf '%s check(s) failed\n' "$failures"
  exit 1
fi
works=$(work_dirs | wc -l | tr -d ' ')
printf 'check-wiki passed: wiki format %s, %s works\n' "$present_format" "$works"
