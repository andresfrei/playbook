#!/bin/sh
# Reads the past reviews of one repository from the person's Claude Code
# transcripts (seed-evidence-7, N1 and N2 of the work seed-evidence). It never
# writes a file and never calls a model. POSIX sh and awk, with sed for names
# and date for the time zone; no JSON parser.
# Usage: sh seed-reviews.sh list [--from <old path>]... <repository root> [evidence page]
#        sh seed-reviews.sh show [--from <old path>]... <repository root> N
# --from <old path>, which can be repeated (seed-evidence-14), is for a
# repository that was moved: it also reads the transcript folder named after
# that absolute path, by the same name rule, and its --claude-worktrees-*
# session folders, and no other folder (a sibling whose name starts the same is
# not read). The old path need not exist on disk. Its reviews are listed like
# the others. show must be given the same options as list to number the same.
# - list: one line per review, oldest first: its number, its identifier, and
#   "N findings" or "No findings.", plus "already seeded" (see below). N is an
#   estimate: the lines of the report that start with a number and a dot,
#   or with "**" and one, such as "1. " or "**2. "; when there are none it
#   prints "findings". It ends with the number of reviews that have findings
#   and are not seeded yet, which is the number of runs of classify. With no
#   transcript folder or no review it says so and exits 0.
# - show: the identifier of review N on the first line, then its report, with
#   the JSON escapes undone. With no transcript folder or no review N it
#   fails with exit 1.
# The identifier of a review is the date and time of its call, in UTC, as
# "YYYY-MM-DD HH:MM:SS", with the fraction of a second when the transcript has
# one ("2026-11-10 10:00:00.100"); reading the same transcripts twice gives
# the same identifier, so the page counts a review once. A call with no
# timestamp is "undated". When more than one review has the same identifier,
# and for "undated", each gets a space and the last 6 characters of its tool
# use id after it ("2026-11-10 10:00:00.100 abc123", "undated abc123"), so the
# same review always has the same identifier, whatever the order of the files.
# Already seeded: a review is marked when the Review column of the Evidence
# table of the page (default: docs/wiki/evidence.md of the repository) holds
# its identifier, or holds an identifier that ends with a minute,
# "YYYY-MM-DD HH:MM", from the minute of its call to the minute of its result
# (the date of the tool result, or of its task notification), both included.
# A live review writes that minute when it takes the date, from its own Bash
# date, which is local time, often minutes after its call. So the range is
# compared in the local zone only (the offset of date +%z now, so a change of
# summer time may miss by an hour); on a machine set to UTC, local is UTC.
# Two reviews whose minutes fall in the range of one page identifier are both
# marked: a collision, accepted.
# Transcripts: ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<name>, where
# <name> is the absolute path with each byte that is not a letter or a digit
# replaced by "-". The folders read are those of the repository (by its
# logical and its physical path), of each of its git worktrees when the root
# is the top of its git repository, and of its .claude/worktrees/* sessions.
# Only the *.jsonl files at the top of a folder are read, not subagents/.
# A review is a call to an agent ("Agent" or "Task") whose subagent_type
# contains "review". Its report is the tool result of the call, or, for a
# review in the background, the <result> of its task notification, up to the
# last </result> before the end of that notification (the notice "Async agent
# launched successfully" is left out), matched by tool use id.
# Identical reports count once. A report is "No findings." when it has a line
# that is exactly that sentence, as review-ran.sh reads it.
# Unescaping: \n \t \r \b \f \" \\ \/ and \uXXXX, written as UTF-8 (a pair of
# surrogates is joined). Names of folders are made byte by byte, so a path
# with characters outside ASCII may not match what Claude Code made.

usage() {
  printf 'usage: sh seed-reviews.sh list [--from <old path>]... <repository root> [evidence page]\n       sh seed-reviews.sh show [--from <old path>]... <repository root> N\n' >&2
  exit 2
}

mode=${1:-}
case $mode in
  list | show) shift ;;
  *) usage ;;
esac
froms=
npos=0
p1=
p2=
while [ $# -gt 0 ]; do
  case $1 in
    --from)
      [ $# -ge 2 ] || usage
      case $2 in
        /?*) ;;
        *) printf 'seed-reviews: --from needs an absolute path, not "%s"\n' "$2" >&2; exit 2 ;;
      esac
      froms="$froms
$2"
      shift 2 ;;
    -*) usage ;;
    *)
      npos=$((npos + 1))
      case $npos in
        1) p1=$1 ;;
        2) p2=$1 ;;
        *) usage ;;
      esac
      shift ;;
  esac
done
case $mode in
  list) [ "$npos" -ge 1 ] || usage ;;
  show) [ "$npos" -eq 2 ] || usage ;;
esac
root=$p1
[ -d "$root" ] || { printf 'seed-reviews: %s is not a directory\n' "$root" >&2; exit 2; }
root_l=$(cd "$root" && pwd)
root_p=$(cd "$root" && pwd -P)
if [ "$mode" = show ]; then
  case $p2 in
    '' | *[!0-9]*) printf 'seed-reviews: N must be a number\n' >&2; exit 2 ;;
  esac
  want=$p2
else
  want=0
  page=${p2:-$root_l/docs/wiki/evidence.md}
fi

projects=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects

# The folder name of Claude Code for an absolute path.
name_of() { printf '%s' "$1" | LC_ALL=C sed 's/[^A-Za-z0-9]/-/g'; }

folders=
add_folder() {
  [ -d "$1" ] || return 0
  case "
$folders
" in
    *"
$1
"*) return 0 ;;
  esac
  folders="$folders
$1"
}

paths=$root_l
[ "$root_p" = "$root_l" ] || paths="$paths
$root_p"
# The worktrees are those of the repository only when the root is its top: a
# folder inside a repository does not read the repository's transcripts.
wt=
top=$(git -C "$root_p" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$top" ] && top=$(cd "$top" 2>/dev/null && pwd -P) && [ "$top" = "$root_p" ]; then
  wt=$(git -C "$root_p" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')
fi
[ -z "$wt" ] || paths="$paths
$wt"
# The old paths of --from need not exist: their folders are read too, by the
# same name rule, with their .claude/worktrees sessions, and nothing else.
froms=$(printf '%s\n' "$froms" | sed 's|//*$||')
[ -z "$froms" ] || paths="$paths
$froms"
# Without a here-document, a path with a space stays whole: one path per line.
oldifs=$IFS
IFS='
'
for p in $paths; do
  n=$(name_of "$p")
  add_folder "$projects/$n"
  for d in "$projects/$n"--claude-worktrees-*; do add_folder "$d"; done
done
IFS=$oldifs

if [ -z "$folders" ]; then
  if [ "$mode" = list ]; then
    printf 'No Claude Code transcript folder found for %s under %s.\n' "$root_l" "$projects"
    exit 0
  fi
  printf 'seed-reviews: no transcript folder found for %s\n' "$root_l" >&2
  exit 1
fi

# Prints one record per review, oldest first: the identifier, a tab, and the
# report as it is written in the JSON (escaped, on one line).
records() {
  oldifs=$IFS
  IFS='
'
  for d in $folders; do
    for f in "$d"/*.jsonl; do
      [ -f "$f" ] && printf '%s\n' "$f"
    done
  done | LC_ALL=C awk '
  # Reads the inside of a JSON string from the start of s, as written; sets
  # rawlen to its length.
  function rawstr(s) {
    match(s, /^([^"\\]|\\.)*/)
    rawlen = RLENGTH
    return substr(s, 1, RLENGTH)
  }
  # The report at the start of s, which follows "content":.
  function content(s,   out, t, s2) {
    if (substr(s, 1, 1) == "\"") return rawstr(substr(s, 2))
    if (substr(s, 1, 1) != "[") return ""
    s = substr(s, 2); out = ""
    while (substr(s, 1, 23) == "{\"type\":\"text\",\"text\":\"") {
      s2 = substr(s, 24)
      t = rawstr(s2)
      out = out (out == "" ? "" : "\\n") t
      s = substr(s2, rawlen + 2)
      if (substr(s, 1, 1) == ",") s = substr(s, 2)
    }
    return out
  }
  function fmt(t) {
    if (t == "") return "undated"
    sub(/Z$/, "", t); sub(/T/, " ", t)
    return t
  }
  # Removes spaces and the escapes \n \t \r at both ends of an escaped text. An
  # escape at the end counts only when an odd number of backslashes come
  # before its letter: "\\n" is a backslash and an n.
  function trim(t,   k, c) {
    while (t ~ /^(\\[ntr]| )/) sub(/^(\\[ntr]| )/, "", t)
    while (1) {
      if (t ~ / $/) { t = substr(t, 1, length(t) - 1); continue }
      if (t !~ /\\[ntr]$/) break
      k = length(t) - 1; c = 0
      while (k >= 1 && substr(t, k, 1) == "\\") { c++; k-- }
      if (c % 2 == 0) break
      t = substr(t, 1, length(t) - 2)
    }
    return t
  }
  function keep(id, text, ts) {
    text = trim(text)
    if ((id in callts) && !(id in res) && text != "" && text !~ /^Async agent launched successfully/) { res[id] = text; rts[id] = (ts == "" ? "" : fmt(ts)) }
  }
  function process(line,   s, m, a, id, ts, seg, st, i, j, b, nxt) {
    if (index(line, "toolu_") == 0) return
    ts = ""
    if (match(line, /"timestamp":"[^"]*"/)) ts = substr(line, RSTART + 13, RLENGTH - 14)
    s = line
    while (match(s, /"id":"toolu_[A-Za-z0-9_]+","name":"(Agent|Task)","input":/)) {
      m = substr(s, RSTART, RLENGTH)
      split(m, a, "\"")
      id = a[4]
      s = substr(s, RSTART + RLENGTH)
      seg = s
      if (match(seg, /"id":"toolu_[A-Za-z0-9_]+","name":"/)) seg = substr(seg, 1, RSTART - 1)
      if (!match(seg, /"subagent_type":"[^"]*"/)) continue
      st = tolower(substr(seg, RSTART + 17, RLENGTH - 18))
      if (st !~ /review/) continue
      # The same call can be written on more than one line; the first line
      # with a timestamp gives the date.
      if (!(id in callts)) { callts[id] = fmt(ts); order[++nc] = id }
      else if (callts[id] == "undated") callts[id] = fmt(ts)
    }
    s = line
    while (match(s, /"tool_use_id":"toolu_[A-Za-z0-9_]+"[^][{}]*"content":/)) {
      m = substr(s, RSTART, RLENGTH)
      split(m, a, "\"")
      id = a[4]
      s = substr(s, RSTART + RLENGTH)
      if (id in callts) keep(id, content(s), ts)
    }
    if (index(line, "<task-notification>") == 0) return
    s = line
    while ((i = index(s, "<tool-use-id>")) > 0) {
      s = substr(s, i + 13)
      j = index(s, "</tool-use-id>")
      if (!j) break
      id = substr(s, 1, j - 1)
      s = substr(s, j + 14)
      b = index(s, "<result>"); nxt = index(s, "<tool-use-id>")
      if (!b || (nxt && nxt < b)) continue
      s = substr(s, b + 8)
      # The notification ends at a </task-notification> that is followed by the
      # closing quote of the JSON string; a report may quote the tag itself,
      # and then it is followed by more text, or by \". Without such an end,
      # at the first tag. The report ends at the last </result> before it.
      e = index(s, "</task-notification>\"")
      if (!e) e = index(s, "</task-notification>")
      seg = (e ? substr(s, 1, e - 1) : s)
      j = 0; p = 0
      while ((q = index(substr(seg, p + 1), "</result>")) > 0) { p += q; j = p }
      if (!j) break
      keep(id, substr(s, 1, j - 1), ts)
      s = substr(s, (e ? e : j + 9))
    }
  }
  { files[++nf] = $0 }
  END {
    for (k = 1; k <= nf; k++) {
      while ((getline line < files[k]) > 0) process(line)
      close(files[k])
    }
    n = 0
    for (k = 1; k <= nc; k++) {
      id = order[k]
      if (!(id in res)) continue
      if (res[id] in seen) {
        # An identical report: keep the earlier call, and for equal dates the
        # smaller tool use id, so the choice does not depend on file order.
        e = seen[res[id]]
        if (callts[id] < ts_of[e] || (callts[id] == ts_of[e] && id < tid[e])) { ts_of[e] = callts[id]; tid[e] = id; hi[e] = rts[id] }
        continue
      }
      n++; seen[res[id]] = n; ts_of[n] = callts[id]; tid[n] = id; hi[n] = rts[id]; body[n] = res[id]
      cnt[callts[id]]++
    }
    # Insertion sort by date, then by tool use id.
    for (a = 1; a <= n; a++) { o[a] = a }
    for (a = 2; a <= n; a++) {
      v = o[a]; b = a - 1
      while (b >= 1 && (ts_of[o[b]] > ts_of[v] || (ts_of[o[b]] == ts_of[v] && tid[o[b]] > tid[v]))) { o[b + 1] = o[b]; b-- }
      o[b + 1] = v
    }
    # A date that more than one review has, and "undated", get the last 6
    # characters of the tool use id after them: the same review always has the
    # same identifier. The second field is the date of the result.
    for (a = 1; a <= n; a++) {
      id = ts_of[o[a]]
      if (cnt[id] > 1 || id == "undated") id = id " " substr(tid[o[a]], length(tid[o[a]]) - 5)
      printf "%s\t%s\t%s\n", id, hi[o[a]], body[o[a]]
    }
  }'
  IFS=$oldifs
}

# The identifiers in the Review column of the Evidence table of the page.
seeded_ids() {
  [ -f "$page" ] || return 0
  awk '
    /^```/ { fence = !fence; next }
    fence { next }
    /^## / { h = $0; sub(/^## +/, "", h); sub(/[ \t\r]+$/, "", h); sec = (h == "Evidence"); next }
    sec && /^\|/ {
      line = $0; gsub(/\\\|/, "\001", line)
      n = split(line, c, "|")
      v = c[4]; gsub(/^[ \t]+|[ \t\r]+$/, "", v); gsub(/\001/, "|", v)
      if (v != "") print v
    }' "$page"
}

if [ "$mode" = list ]; then
  seeded=$(seeded_ids)
  tz=$(date +%z 2>/dev/null)
  records | awk -F '\t' -v seeded="$seeded" -v root="$root_l" -v tz="$tz" '
    # Days since 1970-01-01 of a date, and the date of a day count (civil
    # calendar arithmetic); the date of the second is left in Y, M, D.
    function days(y, m, d,   era, yoe, doy) {
      if (m <= 2) y--
      era = int(y / 400); yoe = y - era * 400
      doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
      return era * 146097 + yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy - 719468
    }
    function civil(z,   era, doe, yoe, doy, mp) {
      z += 719468; era = int(z / 146097); doe = z - era * 146097
      yoe = int((doe - int(doe / 1460) + int(doe / 36524) - int(doe / 146096)) / 365)
      Y = yoe + era * 400; doy = doe - (365 * yoe + int(yoe / 4) - int(yoe / 100))
      mp = int((5 * doy + 2) / 153); D = doy - int((153 * mp + 2) / 5) + 1
      M = mp + (mp < 10 ? 3 : -9)
      if (M <= 2) Y++
    }
    # The minute of an identifier, "YYYY-MM-DD HH:MM", moved by off minutes.
    function moved(id, off,   t, z, r) {
      t = days(substr(id, 1, 4) + 0, substr(id, 6, 2) + 0, substr(id, 9, 2) + 0) * 1440 + substr(id, 12, 2) * 60 + substr(id, 15, 2) + off
      z = int(t / 1440); if (t - z * 1440 < 0) z--
      r = t - z * 1440
      civil(z)
      return sprintf("%04d-%02d-%02d %02d:%02d", Y, M, D, int(r / 60), r % 60)
    }
    function isminute(s) { return s ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]/ }
    # Is a minute of the page between lo and hi, inclusive?
    function inrange(lo, hi,   k) {
      for (k in tail) if (k >= lo && k <= hi) return 1
      return 0
    }
    # A review is seeded when the page has its identifier, or an identifier
    # that ends with a minute from the minute of its call to the minute of its
    # result (rts), in the local zone (off minutes from UTC).
    function isseeded(id, rts,   lo, hi) {
      if (id in done) return 1
      if (!isminute(id)) return 0
      lo = substr(id, 1, 16); hi = (isminute(rts) ? substr(rts, 1, 16) : lo)
      if (hi < lo) hi = lo
      return inrange(moved(lo, off), moved(hi, off))
    }
    BEGIN {
      off = 0
      if (tz ~ /^[-+][0-9][0-9][0-9][0-9]$/) off = (substr(tz, 1, 1) == "-" ? -1 : 1) * (substr(tz, 2, 2) * 60 + substr(tz, 4, 2))
      n = split(seeded, s, "\n")
      for (i = 1; i <= n; i++) {
        if (s[i] == "") continue
        done[s[i]] = 1
        if (s[i] ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9]$/) tail[substr(s[i], length(s[i]) - 15)] = 1
      }
    }
    {
      total++
      raw = $3
      none = (raw ~ /(^|\\n)No findings\.(\\n|$)/)
      count = 0
      m = split(raw, ln, "\\\\n")
      for (i = 1; i <= m; i++) if (ln[i] ~ /^(\*\*)?[0-9]+\.[ *]/) count++
      what = (count == 0 ? "findings" : (count == 1 ? "1 finding" : count " findings"))
      line = total "  " $1 "  " (none ? "No findings." : what)
      sd = isseeded($1, $2)
      if (sd) line = line "  already seeded"
      print line
      if (!none) { withf++; if (!sd) runs++ }
    }
    END {
      if (total == 0) { print "No reviews found in the transcripts of " root "."; exit }
      printf "%d reviews, %d with findings, %d with findings and not seeded yet.\n", total, withf, runs
      printf "Runs of classify: %d\n", runs
    }'
  exit 0
fi

records | LC_ALL=C awk -F '\t' -v want="$want" '
  # Writes code point c as UTF-8.
  function utf8(c) {
    if (c < 128) return sprintf("%c", c)
    if (c < 2048) return sprintf("%c%c", 192 + int(c / 64), 128 + c % 64)
    if (c < 65536) return sprintf("%c%c%c", 224 + int(c / 4096), 128 + int(c / 64) % 64, 128 + c % 64)
    return sprintf("%c%c%c%c", 240 + int(c / 262144), 128 + int(c / 4096) % 64, 128 + int(c / 64) % 64, 128 + c % 64)
  }
  function hexval(h,   i, v) {
    v = 0
    for (i = 1; i <= length(h); i++) v = v * 16 + index("0123456789abcdef", tolower(substr(h, i, 1))) - 1
    return v
  }
  function unescape(s,   out, p, d, c, h, lo) {
    out = ""
    while ((p = index(s, "\\")) > 0) {
      out = out substr(s, 1, p - 1)
      d = substr(s, p + 1, 1); s = substr(s, p + 2)
      if (d == "n") out = out "\n"
      else if (d == "t") out = out "\t"
      else if (d == "r") out = out "\r"
      else if (d == "b") out = out "\b"
      else if (d == "f") out = out "\f"
      else if (d == "u" && substr(s, 1, 4) ~ /^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$/) {
        c = hexval(substr(s, 1, 4)); s = substr(s, 5)
        if (c >= 55296 && c < 56320 && substr(s, 1, 2) == "\\u" && substr(s, 3, 4) ~ /^[dD][c-fC-F][0-9a-fA-F][0-9a-fA-F]$/) {
          lo = hexval(substr(s, 3, 4)); s = substr(s, 7)
          c = 65536 + (c - 55296) * 1024 + (lo - 56320)
        }
        out = out utf8(c)
      } else out = out d
    }
    return out s
  }
  NR == want { print $1; print unescape($3); found = 1 }
  END { if (!found) { printf "seed-reviews: there is no review %s\n", want > "/dev/stderr"; exit 1 } }'
