#!/bin/sh
# Finds the secret files of a repository by name and adds the chosen
# protections to a Claude Code settings file (N4 and N5 of the work
# ask-before-irreversible). POSIX sh and awk, no jq or python. It never reads
# the content of a file it lists, and it never removes a rule.
# Usage: sh protect.sh scan [dir]
#        sh protect.sh apply <settings file> <item>...
# - scan: one path per line, relative to dir (default: the git root of the
#   current directory, else the current directory), sorted, of the files named
#   .env, .env.*, *.pem, *.key, id_rsa*, *credentials*, *.p12, or secrets.*,
#   tracked by git or not, skipping every .git and node_modules folder. A name
#   with a double quote, a backslash, a control character, or a wildcard
#   (* ? [ ]) is not listed and is reported on standard error. A symbolic link
#   with such a name is listed; a folder link is not followed. Nothing found is not an error.
# - apply: the items are
#     secret:<path>    Read(./<path>) in permissions.deny, and ./<path> in
#                      sandbox.filesystem.denyRead. The path is relative to
#                      the project root, where the person runs apply, so both
#                      forms stay relative. A path with a wildcard (* ? [ ]), a
#                      quote, a backslash, or a . or .. component is refused
#                      (exit 2), since the rule is a gitignore pattern.
#     deletes          in permissions.ask: Bash(rm -r *), Bash(rm -rf *),
#                      Bash(git reset --hard *), Bash(git branch -D *),
#                      Bash(git clean *)
#     sandbox          sandbox.enabled true
#     no-unsandboxed   sandbox.allowUnsandboxedCommands false
#   A missing file, and its folder, are created holding {}. A string already in
#   its array is not added twice; a boolean replaces the value of its key; no
#   other key changes. Every item is applied to a temporary copy, and the file
#   is replaced only when all succeeded and something changed. It prints one
#   line per thing added or set, and "already there" for what it skipped.
# Exit codes: 0 done; 2 bad arguments or an unknown item; 3 the file is not
# valid JSON, is not an object, has an object key with a slash or an escape,
# or a part of a path has another type (the file is untouched); 4 a file or
# folder could not be written, or the settings file is a symbolic link. A
# rewrite keeps the mode of the file.
# Decisions: ask-before-irreversible-9 (what is protected, chosen item by
# item), -10 (the file is the person's choice, and nothing else changes), -14
# (find by name, json_add, no new dependency), -15 (the rules of each item).
#
# json_walk, json_add, and json_strings are copies of those in
# plugins/playbook/skills/init/scripts/init.sh, since playbook-agents may be
# installed without the playbook plugin; this copy of json_walk also keeps
# where each literal starts and ends (lstart, lend) and its text (lit), for
# json_set_bool. This copy of json_walk is also strict (see its comment) where
# the one in init.sh is not; keep the rest of the copies alike.
set -u

json_readstr='
function readstr(p,   out, c, d, hex) {
  out = ""; esc = 0
  while (p <= n) {
    c = substr(text, p, 1)
    if (c == "\"") { str = out; pos = p + 1; return 1 }
    if (c == "\\") {
      esc = 1
      p++; d = substr(text, p, 1)
      if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"
      else if (d == "b" || d == "f") c = " "
      else if (d == "u") { p += 4; c = "?" }
      else c = d
    }
    out = out c
    p++
  }
  return 0
}'

# The walker is strict: a colon after each key, a comma between members and
# elements, only true, false, null, and JSON numbers as literals. A key with a
# slash or an escape is refused (bad), since a path is its keys joined by a
# slash. The state of each open level is st[depth]: in an object, 0 expects a
# key or the end, 1 a colon, 2 a value, 3 a comma or the end, 4 a key; in an
# array, 0 expects a value or the end, 3 a comma or the end, 4 a value.
json_walk="$json_readstr"'
function path_at(d,   i, s) { s = ""; for (i = 1; i <= d; i++) s = s (i > 1 ? "/" : "") key[i]; return s }
function fin() { if (depth == 0) done = 1; else st[depth] = 3 }
function walk(   c, q, at, t, s, lt) {
  n = length(text); p = 1; depth = 0; done = 0; bad = 0; st[0] = 2
  while (p <= n) {
    c = substr(text, p, 1)
    if (c ~ /[ \t\n\r]/) { p++; continue }
    if (done) { bad = 1; return }
    t = type[depth]; s = st[depth]
    if (c == ",") { if (depth == 0 || s != 3) { bad = 1; return }; st[depth] = 4; p++; continue }
    if (c == ":") { if (t != "o" || s != 1) { bad = 1; return }; st[depth] = 2; p++; continue }
    if (c == "}" || c == "]") {
      if (depth == 0 || t != (c == "}" ? "o" : "a") || (s != 0 && s != 3)) { bad = 1; return }
      depth--; fin(); p++; continue
    }
    if (c == "\"" && t == "o" && (s == 0 || s == 4)) {
      if (!readstr(p + 1)) { bad = 1; return }
      p = pos
      if (esc || index(str, "/") > 0) { bad = 1; return }
      key[depth] = str; st[depth] = 1; empty[path_at(depth - 1)] = 0
      continue
    }
    if (!(depth == 0 || (t == "o" && s == 2) || (t == "a" && (s == 0 || s == 4)))) { bad = 1; return }
    if (t == "a") empty[path_at(depth - 1)] = 0
    if (c == "{" || c == "[") {
      at = path_at(depth)
      if (!(at in kind)) { kind[at] = (c == "{" ? "o" : "a"); open[at] = p; empty[at] = 1 }
      else if (open[at] == "") open[at] = p
      depth++; type[depth] = (c == "{" ? "o" : "a"); st[depth] = 0; key[depth] = (c == "{" ? "" : "#")
      p++; continue
    }
    if (c == "\"") {
      if (!readstr(p + 1)) { bad = 1; return }
      p = pos
      at = path_at(depth)
      if (!(at in kind)) kind[at] = "s"
      if (at == want) strings[++count] = str
      fin(); continue
    }
    q = p
    while (p <= n && substr(text, p, 1) !~ /[,}\] \t\n\r]/) p++
    lt = substr(text, q, p - q)
    if (lt != "true" && lt != "false" && lt != "null" && lt !~ /^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?$/) { bad = 1; return }
    at = path_at(depth)
    if (!(at in kind)) { kind[at] = "l"; lstart[at] = q; lend[at] = p; lit[at] = lt }
    fin()
  }
  if (depth != 0 || !done) bad = 1
}'

# json_strings <file> <path of an array>: each string in that array, one per
# line; nothing when the file is missing or is not JSON.
json_strings() {
  [ -f "$1" ] || return 0
  awk -v want="$2/#" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END { walk(); if (bad) exit; for (i = 1; i <= count; i++) print strings[i] }' "$1"
}

# json_add <file> <path of an array> <name>: prints the file with the name
# added at the start of that array, creating the objects and the array that
# are missing, and unchanged when the array holds it. Exits 3 when the text is
# not a JSON object or a part of the path has another type.
json_add() {
  awk -v want="$2/#" -v array="$2" -v val="$3" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      walk()
      if (bad || kind[""] != "o") exit 3
      for (i = 1; i <= count; i++) if (strings[i] == val) { print text; exit }
      if (array in kind) {
        if (kind[array] != "a") exit 3
        o = open[array]
        printf "%s\"%s\"%s%s\n", substr(text, 1, o), val, (empty[array] ? "" : ","), substr(text, o + 1)
        exit
      }
      k = split(array, part, "/")
      prefix = ""
      for (i = 1; i < k; i++) {
        next_prefix = prefix (i > 1 ? "/" : "") part[i]
        if (!(next_prefix in kind)) break
        if (kind[next_prefix] != "o") exit 3
        prefix = next_prefix
      }
      added = "\"" part[k] "\": [\"" val "\"]"
      for (j = k - 1; j >= i; j--) added = "\"" part[j] "\": {" added "}"
      o = open[prefix]
      printf "%s%s%s%s\n", substr(text, 1, o), added, (empty[prefix] ? "" : ","), substr(text, o + 1)
    }' "$1"
}

# json_literal <file> <path>: the literal (true, false, a number, null) at
# that path; nothing when there is none or the file is not JSON.
json_literal() {
  awk -v want="$2" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END { walk(); if (bad) exit; if (want in lit) print lit[want] }' "$1"
}

# json_set_bool <file> <path of a key> <true|false>: prints the file with the
# literal of that key replaced by the value, or the key added with it,
# creating the objects that are missing. Exits 3 when the text is not a JSON
# object, or a part of the path, or the key itself, is not an object or a
# literal.
json_set_bool() {
  awk -v array="$2" -v val="$3" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      walk()
      if (bad || kind[""] != "o") exit 3
      if (array in kind) {
        if (kind[array] != "l") exit 3
        print substr(text, 1, lstart[array] - 1) val substr(text, lend[array])
        exit
      }
      k = split(array, part, "/")
      prefix = ""
      for (i = 1; i < k; i++) {
        next_prefix = prefix (i > 1 ? "/" : "") part[i]
        if (!(next_prefix in kind)) break
        if (kind[next_prefix] != "o") exit 3
        prefix = next_prefix
      }
      added = "\"" part[k] "\": " val
      for (j = k - 1; j >= i; j--) added = "\"" part[j] "\": {" added "}"
      o = open[prefix]
      printf "%s%s%s%s\n", substr(text, 1, o), added, (empty[prefix] ? "" : ","), substr(text, o + 1)
    }' "$1"
}

usage() {
  cat >&2 <<'USAGE'
Usage: protect.sh scan [dir]
       protect.sh apply <settings file> <item>...
Items: secret:<path>, deletes, sandbox, no-unsandboxed
Exit codes: 0 done; 2 bad arguments or an unknown item; 3 the file is not a
valid JSON object, or a part of a path has another type; 4 a write failed or
the file is a symbolic link.
USAGE
}

# unsafe_name <text>: succeeds when it holds a double quote, a backslash, a
# control character, or a wildcard (* ? [ ]), which a JSON string would need to
# escape or a gitignore pattern would read as a pattern.
unsafe_name() {
  _bs=$(printf '\134')
  _q='"'
  case $1 in
    *"$_q"*|*"$_bs"*|*[[:cntrl:]]*|*\**|*\?*|*\[*|*\]*) return 0 ;;
  esac
  return 1
}

scan() {
  if [ $# -ge 1 ]; then
    dir=$1
  else
    dir=$(git rev-parse --show-toplevel 2>/dev/null) || dir=$(pwd)
  fi
  [ -d "$dir" ] || { printf 'protect.sh: not a folder: %s\n' "$dir" >&2; exit 2; }
  cd "$dir" || exit 2
  find . \( -name .git -o -name node_modules \) -prune -o \( -type f -o -type l \) \
    \( -name .env -o -name '.env.*' -o -name '*.pem' -o -name '*.key' \
       -o -name 'id_rsa*' -o -name '*credentials*' -o -name '*.p12' \
       -o -name 'secrets.*' \) -exec sh -c '
    for f; do
      f=${f#./}
      bs=$(printf "\\\\")
      case $f in
        *\"*|*"$bs"*|*[[:cntrl:]]*|*\**|*\?*|*\[*|*\]*)
          printf "protect.sh: skipped, the name has a quote, a backslash, a control character, or a wildcard (* ? [ ]): %s\n" \
            "$(printf %s "$f" | tr -c "[:print:]" "?")" >&2 ;;
        *) printf "%s\n" "$f" ;;
      esac
    done' sh {} + | LC_ALL=C sort
}

apply() {
  [ $# -ge 2 ] || { usage; exit 2; }
  file=$1; shift
  if [ -L "$file" ]; then
    printf 'protect.sh: %s is a symbolic link: not written; give the file it points to\n' "$file" >&2
    exit 4
  fi
  # Check every item before touching anything.
  for item in "$@"; do
    case $item in
      secret:*)
        p=${item#secret:}
        while :; do case $p in ./*) p=${p#./} ;; *) break ;; esac; done
        case $p in
          ''|/*|.|./*|*/.|*/./*|..|../*|*/..|*/../*) printf 'protect.sh: not a path inside the project: %s\n' "$item" >&2; exit 2 ;;
        esac
        if unsafe_name "$p"; then
          printf 'protect.sh: the path has a quote, a backslash, a control character, or a wildcard (* ? [ ]): %s\n' "$item" >&2
          exit 2
        fi ;;
      deletes|sandbox|no-unsandboxed) ;;
      *) printf 'protect.sh: unknown item: %s\n' "$item" >&2; usage; exit 2 ;;
    esac
  done

  work=$(mktemp "${TMPDIR:-/tmp}/protect.XXXXXX") || { printf 'protect.sh: could not make a temporary file\n' >&2; exit 4; }
  msgs=$(mktemp "${TMPDIR:-/tmp}/protect.XXXXXX") || { rm -f "$work"; exit 4; }
  trap 'rm -f "$work" "$work.new" "$msgs"' EXIT
  trap 'exit 4' HUP INT TERM
  if [ -e "$file" ]; then
    if [ ! -f "$file" ] || ! cp "$file" "$work"; then printf 'protect.sh: cannot read %s\n' "$file" >&2; exit 4; fi
  else
    printf '{}\n' > "$work"
  fi
  changed=0
  [ -e "$file" ] || changed=1

  # add <array path> <string>
  add() {
    if json_strings "$work" "$1" | grep -Fxq -- "$2"; then
      printf 'already there: %s in %s\n' "$2" "$1" >> "$msgs"
      return 0
    fi
    json_add "$work" "$1" "$2" > "$work.new"
    code=$?
    if [ "$code" -ne 0 ]; then
      printf 'protect.sh: %s is not a JSON object, or %s has another type: nothing written\n' "$file" "$1" >&2
      exit 3
    fi
    mv "$work.new" "$work" || exit 4
    printf 'added: %s in %s\n' "$2" "$1" >> "$msgs"
    changed=1
  }

  # set_bool <key path> <true|false>
  set_bool() {
    if [ "$(json_literal "$work" "$1")" = "$2" ]; then
      printf 'already there: %s is %s\n' "$1" "$2" >> "$msgs"
      return 0
    fi
    json_set_bool "$work" "$1" "$2" > "$work.new"
    code=$?
    if [ "$code" -ne 0 ]; then
      printf 'protect.sh: %s is not a JSON object, or %s has another type: nothing written\n' "$file" "$1" >&2
      exit 3
    fi
    mv "$work.new" "$work" || exit 4
    printf 'set: %s is %s\n' "$1" "$2" >> "$msgs"
    changed=1
  }

  for item in "$@"; do
    case $item in
      secret:*)
        p=${item#secret:}
        while :; do case $p in ./*) p=${p#./} ;; *) break ;; esac; done
        add permissions/deny "Read(./$p)"
        add sandbox/filesystem/denyRead "./$p" ;;
      deletes)
        add permissions/ask "Bash(rm -r *)"
        add permissions/ask "Bash(rm -rf *)"
        add permissions/ask "Bash(git reset --hard *)"
        add permissions/ask "Bash(git branch -D *)"
        add permissions/ask "Bash(git clean *)" ;;
      sandbox) set_bool sandbox/enabled true ;;
      no-unsandboxed) set_bool sandbox/allowUnsandboxedCommands false ;;
    esac
  done

  if [ "$changed" -eq 0 ]; then
    cat "$msgs"
    exit 0
  fi
  dir=$(dirname "$file")
  mkdir -p "$dir" || { printf 'protect.sh: could not make %s\n' "$dir" >&2; exit 4; }
  # The copy keeps the mode and owner of an existing file; a new file gets the
  # mode the umask gives.
  if [ -e "$file" ]; then
    cp -p "$file" "$file.protect.$$" || { rm -f "$file.protect.$$"; exit 4; }
  fi
  cat "$work" > "$file.protect.$$" || { rm -f "$file.protect.$$"; exit 4; }
  mv "$file.protect.$$" "$file" || { rm -f "$file.protect.$$"; exit 4; }
  cat "$msgs"
}

[ $# -ge 1 ] || { usage; exit 2; }
cmd=$1; shift
case $cmd in
  scan) [ $# -le 1 ] || { usage; exit 2; }; scan "$@" ;;
  apply) apply "$@" ;;
  *) usage; exit 2 ;;
esac
