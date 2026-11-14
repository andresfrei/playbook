#!/bin/sh
# Compares the format of a project's wiki with the format the playbook is at,
# and marks a wiki as brought to it.
# Usage: sh wiki-format.sh status [wiki directory]    (default: docs/wiki)
#        sh wiki-format.sh mark [wiki directory]
#        sh wiki-format.sh hook
# status prints nothing when there is no wiki, or when its marker is at the
# playbook's format or above, and one line when the marker is missing or
# behind. It always exits 0.
# hook is status for the project of a Claude Code session, which it reads from
# CLAUDE_PROJECT_DIR. It prints nothing when that variable is not set.
# mark writes the marker only when the wiki has a "Where work stands" section
# and the check of the wiki passes.
set -u

# The format of a wiki the playbook is at. Raise it only together with a new
# references/format-<number>.md that says how a wiki reaches it.
format=2

command=${1:-}
if [ "$command" = hook ]; then
  [ -n "${CLAUDE_PROJECT_DIR:-}" ] || exit 0
  command=status
  set -- status "$CLAUDE_PROJECT_DIR/docs/wiki"
fi
wiki=${2:-docs/wiki}
wiki=${wiki%/}
marker="$wiki/.format"

# Prints the number in the marker, or nothing when the marker is missing or
# does not hold a number of at most nine digits.
wiki_format() {
  [ -f "$marker" ] || return 0
  value=$(head -n 1 "$marker" | tr -d ' \t\r')
  case $value in
    ''|*[!0-9]*|??????????*) ;;
    *) printf '%s' "$value" ;;
  esac
}

advice='Tell the owner, and recommend running the doctor skill (/playbook:doctor). Do not repair the wiki unasked.'

case $command in
  status)
    [ -f "$wiki/README.md" ] || exit 0
    current=$(wiki_format)
    if [ -z "$current" ]; then
      printf 'The wiki of this project has no format marker, and the playbook is at wiki format %s. %s\n' "$format" "$advice"
    elif [ "$current" -lt "$format" ]; then
      printf 'The wiki of this project is at wiki format %s, and the playbook is at %s. %s\n' "$current" "$format" "$advice"
    fi
    exit 0 ;;
  mark)
    if [ ! -f "$wiki/README.md" ]; then
      printf 'FAIL %s has no README.md\n' "$wiki"
      exit 1
    fi
    if ! grep -q '^##*[[:space:]][[:space:]]*Where work stands' "$wiki/README.md"; then
      printf 'FAIL %s/README.md has no "Where work stands" section, so the wiki is not in the format of the playbook. The marker was not written.\n' "$wiki"
      exit 1
    fi
    if ! sh "$(dirname "$0")/../../prepare-project/scripts/check-wiki.sh" "$wiki"; then
      printf 'The marker was not written.\n'
      exit 1
    fi
    if ! printf '%s\n' "$format" 2>/dev/null > "$marker"; then
      printf 'FAIL could not write %s. The marker was not written.\n' "$marker"
      exit 1
    fi
    printf 'marked %s as wiki format %s\n' "$wiki" "$format" ;;
  *)
    printf 'Usage: sh wiki-format.sh status|mark [wiki directory], or sh wiki-format.sh hook\n'
    exit 2 ;;
esac
