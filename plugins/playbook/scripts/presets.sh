#!/bin/sh
# Saves, detects, applies, and records a preset (presets-1 to presets-8).
# A preset is a bundle of signal files, permission rules, skills, and agents.
#
# Base folder: ${PLAYBOOK_HOME:-$HOME/.claude/playbook}
#   presets/NAME/signals       one relative path per line
#   presets/NAME/rules.json    {"allow":[],"ask":[],"deny":[]}
#   presets/NAME/skills/SKILL/ a copied folder
#   presets/NAME/agents/AGENT.md
#   registry.json              {"<absolute physical project path>": ["NAME", ...]}
#
# Usage:
#   sh presets.sh save NAME PROJECT [signal FILE | allow RULE | ask RULE | deny RULE | skill SKILL | agent AGENT]...
#     Writes the preset from PROJECT (skills from PROJECT/.claude/skills/SKILL/,
#     agents from PROJECT/.claude/agents/AGENT.md). Rules are stored literally,
#     deduped, order kept. Refuses: the preset exists; no signal; a signal file,
#     skill, or agent missing in PROJECT. A refusal leaves nothing behind.
#   sh presets.sh detect PROJECT
#     Prints, sorted, one per line, the presets whose signal files all exist in
#     PROJECT. A preset with no signal is never listed.
#   sh presets.sh apply NAME PROJECT [overwrite skill:SKILL | overwrite agent:AGENT]...
#     Writes the rules into PROJECT/.claude/settings.json (through
#     settings-write.sh), copies skills and agents into PROJECT/.claude/, and adds
#     NAME to the project's entry in the registry, once. A skill or agent already
#     there with different content is a conflict: refused, nothing written, unless
#     named by overwrite. A second identical apply changes nothing.
#
# NAME, SKILL, and AGENT match [A-Za-z0-9._-]+ and do not start with a dot.
# Errors go to stderr with exit 1. Without jq it says so and writes nothing.
die() { printf 'presets: %s\n' "$*" >&2; exit 1; }

usage="usage: presets.sh save NAME PROJECT [signal FILE|allow RULE|ask RULE|deny RULE|skill SKILL|agent AGENT]... | detect PROJECT | apply NAME PROJECT [overwrite skill:SKILL|agent:AGENT]..."

command -v jq >/dev/null 2>&1 || die "jq is required and was not found on PATH; nothing was written"

base=${PLAYBOOK_HOME:-$HOME/.claude/playbook}
presets=$base/presets
here=$(dirname "$0")

# valid_name NAME: letters, digits, dot, underscore, dash; no leading dot.
valid_name() {
  case $1 in
    '' | .* | *[!A-Za-z0-9._-]*) return 1 ;;
  esac
  return 0
}

# project_dir PATH: prints the physical absolute path or dies.
project_dir() {
  [ -d "$1" ] || die "project folder '$1' not found"
  (CDPATH='' cd -- "$1" && pwd -P) || die "cannot enter '$1'"
}

cmd=${1:-}
[ -n "$cmd" ] || die "$usage"
shift

case $cmd in
  save)
    [ $# -ge 2 ] || die "$usage"
    name=$1
    valid_name "$name" || die "bad preset name '$name'"
    proj=$(project_dir "$2") || exit 1
    shift 2
    [ ! -e "$presets/$name" ] || die "preset '$name' already exists"
    mkdir -p "$presets" || die "cannot create $presets"
    tmp=$(mktemp -d "$presets/.save.XXXXXX") || die "cannot create a temporary folder in $presets"
    trap 'rm -rf "$tmp"' EXIT
    : > "$tmp/signals"
    printf '{"allow":[],"ask":[],"deny":[]}\n' > "$tmp/rules.json"
    mkdir "$tmp/skills" "$tmp/agents"
    while [ $# -gt 0 ]; do
      [ $# -ge 2 ] || die "'$1' needs a value"
      kw=$1
      val=$2
      shift 2
      case $kw in
        signal)
          case $val in
            '' | /* | .. | ../* | */.. | */../*) die "bad signal path '$val'" ;;
          esac
          [ -e "$proj/$val" ] || die "signal '$val' not found in $proj"
          grep -qxF -- "$val" "$tmp/signals" || printf '%s\n' "$val" >> "$tmp/signals"
          ;;
        allow | ask | deny)
          jq --arg k "$kw" --arg r "$val" \
            'if any(.[$k][]; . == $r) then . else .[$k] += [$r] end' \
            "$tmp/rules.json" > "$tmp/rules.new" || die "jq failed"
          mv "$tmp/rules.new" "$tmp/rules.json" || die "cannot update rules"
          ;;
        skill)
          valid_name "$val" || die "bad skill name '$val'"
          [ -d "$proj/.claude/skills/$val" ] || die "skill '$val' not found in $proj/.claude/skills/"
          rm -rf "${tmp:?}/skills/$val"
          cp -RL "$proj/.claude/skills/$val" "$tmp/skills/$val" || die "cannot copy skill '$val'"
          ;;
        agent)
          valid_name "$val" || die "bad agent name '$val'"
          [ -f "$proj/.claude/agents/$val.md" ] || die "agent '$val' not found in $proj/.claude/agents/"
          cp -L "$proj/.claude/agents/$val.md" "$tmp/agents/$val.md" || die "cannot copy agent '$val'"
          ;;
        *) die "unknown keyword '$kw' (use signal, allow, ask, deny, skill or agent)" ;;
      esac
    done
    [ -s "$tmp/signals" ] || die "no signal given; a preset needs at least one"
    [ ! -e "$presets/$name" ] || die "preset '$name' already exists"
    mv "$tmp" "$presets/$name" || die "cannot move the preset into place"
    ;;

  detect)
    [ $# -eq 1 ] || die "$usage"
    proj=$(project_dir "$1") || exit 1
    [ -d "$presets" ] || exit 0
    for d in "$presets"/*/; do
      [ -f "${d}signals" ] || continue
      found=0
      miss=0
      while IFS= read -r line || [ -n "$line" ]; do
        [ -n "$line" ] || continue
        found=1
        [ -e "$proj/$line" ] || miss=1
      done < "${d}signals"
      if [ "$found" = 1 ] && [ "$miss" = 0 ]; then
        d=${d%/}
        printf '%s\n' "${d##*/}"
      fi
    done | sort
    ;;

  apply)
    [ $# -ge 2 ] || die "$usage"
    name=$1
    valid_name "$name" || die "bad preset name '$name'"
    src=$presets/$name
    [ -d "$src" ] || die "preset '$name' not found"
    proj=$(project_dir "$2") || exit 1
    shift 2
    over=
    stmp=
    atmp=
    rtmp=
    trap 'rm -rf "$stmp" "$atmp" "$rtmp"' EXIT
    while [ $# -gt 0 ]; do
      [ "$1" = overwrite ] && [ $# -ge 2 ] || die "$usage"
      case $2 in
        skill:* | agent:*) valid_name "${2#*:}" || die "bad overwrite item '$2'" ;;
        *) die "bad overwrite item '$2' (use skill:SKILL or agent:AGENT)" ;;
      esac
      over="$over
$2"
      shift 2
    done
    reg=$base/registry.json
    if [ -e "$reg" ]; then
      jq -e 'type == "object"' "$reg" >/dev/null 2>&1 || die "$reg is not valid JSON with an object at the top level"
    fi

    # Conflicts first; nothing is written when there is one.
    conflicts=
    for s in "$src"/skills/*/; do
      [ -d "$s" ] || continue
      s=${s%/}
      s=${s##*/}
      dest=$proj/.claude/skills/$s
      [ -e "$dest" ] || [ -L "$dest" ] || continue
      diff -r -q "$src/skills/$s" "$dest" >/dev/null 2>&1 && continue
      case "$over
" in *"
skill:$s
"*) continue ;; esac
      conflicts="$conflicts skill:$s"
    done
    for a in "$src"/agents/*.md; do
      [ -f "$a" ] || continue
      a=${a##*/}
      a=${a%.md}
      dest=$proj/.claude/agents/$a.md
      [ -e "$dest" ] || [ -L "$dest" ] || continue
      diff -r -q "$src/agents/$a.md" "$dest" >/dev/null 2>&1 && continue
      case "$over
" in *"
agent:$a
"*) continue ;; esac
      conflicts="$conflicts agent:$a"
    done
    if [ -n "$conflicts" ]; then
      for c in $conflicts; do
        printf 'presets: conflict: %s already in %s/.claude with different content; use "overwrite %s"\n' "$c" "$proj" "$c" >&2
      done
      exit 1
    fi

    # Preconditions: everything that could fail is checked before the first write.
    for d in "$proj/.claude" "$proj/.claude/skills" "$proj/.claude/agents"; do
      [ -d "$d" ] || { [ ! -e "$d" ] && [ ! -L "$d" ]; } || die "$d is not a folder; nothing was written"
    done
    settings=$proj/.claude/settings.json
    anyrules=0
    for kind in allow ask deny; do
      n=$(jq -r --arg k "$kind" '.[$k] | length' "$src/rules.json") || die "cannot read rules of '$name'"
      [ "$n" -gt 0 ] || continue
      anyrules=1
      if [ -e "$settings" ]; then
        jq -e --arg k "$kind" '(.permissions // {}) | type == "object" and ((.[$k] // []) | type == "array")' "$settings" >/dev/null 2>&1 \
          || die "permissions.$kind of $settings is not usable (permissions must be an object and its lists arrays); nothing was written"
      fi
    done
    if [ "$anyrules" = 1 ]; then
      [ ! -L "$settings" ] || die "$settings is a symlink; nothing was written"
      if [ -e "$settings" ]; then
        [ -f "$settings" ] || die "$settings is not a regular file; nothing was written"
        jq -e 'type == "object"' "$settings" >/dev/null 2>&1 || die "$settings is not valid JSON with an object at the top level; nothing was written"
      fi
    fi
    if [ -e "$reg" ]; then
      jq -e --arg p "$proj" '(.[$p] // []) | type == "array" and all(.[]; type == "string")' "$reg" >/dev/null 2>&1 \
        || die "the registry entry of $proj is not an array of names; nothing was written"
    fi

    # Rules.
    for kind in allow ask deny; do
      n=$(jq -r --arg k "$kind" '.[$k] | length' "$src/rules.json") || die "cannot read rules of '$name'"
      [ "$n" -gt 0 ] || continue
      set --
      i=0
      while [ "$i" -lt "$n" ]; do
        r=$(jq -r --arg k "$kind" --argjson i "$i" '.[$k][$i]' "$src/rules.json") || die "cannot read rules of '$name'"
        set -- "$@" "$r"
        i=$((i + 1))
      done
      sh "$here/settings-write.sh" rule "$proj/.claude/settings.json" "$kind" "$@" || die "cannot write the $kind rules"
    done

    # Skills and agents.
    for s in "$src"/skills/*/; do
      [ -d "$s" ] || continue
      s=${s%/}
      s=${s##*/}
      dest=$proj/.claude/skills/$s
      if [ -e "$dest" ] && diff -r -q "$src/skills/$s" "$dest" >/dev/null 2>&1; then continue; fi
      mkdir -p "$proj/.claude/skills" || die "cannot create $proj/.claude/skills"
      stmp=$(mktemp -d "$proj/.claude/skills/.presets-tmp.XXXXXX") || die "cannot create a temporary folder in $proj/.claude/skills"
      cp -RL "$src/skills/$s" "$stmp/skill" || die "cannot copy skill '$s'"
      rm -rf "$dest"
      mv "$stmp/skill" "$dest" || die "cannot place skill '$s'"
      rm -rf "$stmp"
    done
    for a in "$src"/agents/*.md; do
      [ -f "$a" ] || continue
      a=${a##*/}
      dest=$proj/.claude/agents/$a
      if [ -e "$dest" ] && cmp -s "$src/agents/$a" "$dest"; then continue; fi
      mkdir -p "$proj/.claude/agents" || die "cannot create $proj/.claude/agents"
      atmp=$(mktemp "$proj/.claude/agents/.presets-tmp.XXXXXX") || die "cannot create a temporary file in $proj/.claude/agents"
      cp -L "$src/agents/$a" "$atmp" || die "cannot copy agent '$a'"
      chmod 644 "$atmp"
      rm -rf "$dest"
      mv "$atmp" "$dest" || die "cannot place agent '$a'"
    done

    # Registry.
    mkdir -p "$base" || die "cannot create $base"
    [ -e "$reg" ] || printf '{}\n' > "$reg" || die "cannot create $reg"
    rtmp=$(mktemp "$base/.registry.XXXXXX") || die "cannot create a temporary file in $base"
    jq --arg p "$proj" --arg n "$name" \
      '.[$p] = ((.[$p] // []) | if any(.[]; . == $n) then . else . + [$n] end)' \
      "$reg" > "$rtmp" || die "jq failed; registry unchanged"
    mv "$rtmp" "$reg" || die "cannot replace $reg"
    ;;

  *) die "unknown command '$cmd'. $usage" ;;
esac
