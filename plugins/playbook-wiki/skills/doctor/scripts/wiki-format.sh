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
# mark writes the marker when the wiki has a column "Code it governs" in a
# table of its README.md and the check of the wiki passes. It writes the marker
# first, because the check refuses a wiki whose marker is below the playbook's
# format; when the check fails it puts the old marker back exactly, or deletes
# the marker when there was none, also when the script is interrupted (INT,
# TERM, HUP). It refuses a marker that is a symbolic link. When it succeeds it deletes
# $wiki/.unchecked-decisions, which format 4 does not use.
set -u

check_wiki="$(dirname "$0")/../../../check-wiki.sh"

# The format of a wiki the playbook is at, read from the one place that holds
# it. Raise it there only together with a new references/format-<number>.md
# that says how a wiki reaches it.
format=$(sh "$check_wiki" --format)

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

advice='Tell the owner, and recommend running the doctor skill (/playbook-wiki:doctor). Do not repair the wiki unasked.'

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
    if [ -L "$marker" ]; then
      printf 'FAIL %s is a symbolic link; replace it with a file. The marker was not written.\n' "$marker"
      exit 1
    fi
    if ! sh "$check_wiki" --column "$wiki"; then
      printf 'FAIL %s/README.md has no column "Code it governs" in its table of pages, so the wiki is not at wiki format %s. The marker was not written.\n' "$wiki" "$format"
      exit 1
    fi
    # Keep the old marker, byte for byte, so a failed or interrupted check can
    # put it back.
    saved=
    if [ -f "$marker" ]; then
      saved=$(mktemp)
      if [ -z "$saved" ] || ! cp "$marker" "$saved"; then
        [ -z "$saved" ] || rm -f "$saved"
        printf 'FAIL could not keep a copy of %s. The marker was not written.\n' "$marker"
        exit 1
      fi
    fi
    # From the first write to the end of the check, any exit that is not a
    # success puts the old marker back, or removes the new one, and deletes the
    # copy. An interrupt is handled when the running check ends.
    armed=0
    undo() {
      if [ "$armed" = 1 ]; then
        armed=0
        if [ -n "$saved" ]; then cp "$saved" "$marker"; else rm -f "$marker"; fi
      fi
      [ -z "$saved" ] || rm -f "$saved"
    }
    trap undo EXIT
    trap 'exit 1' INT TERM HUP
    armed=1
    if ! printf '%s\n' "$format" 2>/dev/null > "$marker"; then
      armed=0
      printf 'FAIL could not write %s. The marker was not written.\n' "$marker"
      exit 1
    fi
    if ! sh "$check_wiki" "$wiki"; then
      undo
      printf 'The marker was not written.\n'
      exit 1
    fi
    armed=0
    undo
    trap - EXIT INT TERM HUP
    rm -f "$wiki/.unchecked-decisions"
    printf 'marked %s as wiki format %s\n' "$wiki" "$format" ;;
  *)
    printf 'Usage: sh wiki-format.sh status|mark [wiki directory], or sh wiki-format.sh hook\n'
    exit 2 ;;
esac
