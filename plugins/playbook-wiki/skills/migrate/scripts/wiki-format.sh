#!/bin/sh
# Compares the format of a project's wiki with the format the playbook is at,
# and marks a wiki as brought to it.
# Usage: sh wiki-format.sh status [wiki directory]    (default: docs/wiki)
#        sh wiki-format.sh mark [wiki directory]
#        sh wiki-format.sh hook
#        sh wiki-format.sh --help
# Exit codes: 0 done; 1 the check of the wiki failed or was interrupted;
# 2 a wrong call; 3 the wiki is not ready to be marked; 4 a file could not be
# copied, written, or removed. Messages go to standard error.
# status prints nothing when there is no wiki, or when its marker is at the
# playbook's format or above, and one line when the marker is missing or
# behind. It always exits 0.
# hook is for the project of a Claude Code session, which it reads from
# CLAUDE_PROJECT_DIR; it prints nothing when that variable is not set. Where
# status prints a line, it prints one JSON object: systemMessage for the person,
# and the line of status as additionalContext for the agent. It also does so
# when the wiki's marker is above the playbook's format, which means the
# plugins are older than the wiki. It always exits 0.
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
# it. Raise it there only together with a change of format.md
# that says what the format is.
format=$(sh "$check_wiki" --format)

command=${1:-}
usage='Usage: sh wiki-format.sh status|mark [wiki directory], sh wiki-format.sh hook, or sh wiki-format.sh --help.
Exit codes: 0 done; 1 the check of the wiki failed or was interrupted; 2 a wrong call; 3 the wiki is not ready to be marked; 4 a file could not be copied, written, or removed.'
if [ "$command" = hook ]; then
  [ -n "${CLAUDE_PROJECT_DIR:-}" ] || exit 0
  set -- hook "$CLAUDE_PROJECT_DIR/docs/wiki"
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

advice='Tell the owner, and recommend running the migrate skill (/playbook-wiki:migrate). Do not repair the wiki unasked.'

# notice <message for the person> <context for the agent>: one JSON object for a
# SessionStart hook. Both texts are fixed sentences with numbers, so nothing in
# them needs escaping.
notice() {
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$1" "$2"
}

case $command in
  hook)
    [ -f "$wiki/README.md" ] || exit 0
    current=$(wiki_format)
    if [ -z "$current" ]; then
      notice "This project's wiki has no format marker, and the playbook is at wiki format $format. Run /playbook-wiki:migrate to bring it to that format." \
        "The wiki of this project has no format marker, and the playbook is at wiki format $format. The person was shown this at the start of the session; recommend running the migrate skill (/playbook-wiki:migrate). Do not repair the wiki unasked."
    elif [ "$current" -lt "$format" ]; then
      notice "This project's wiki is at format $current, and the playbook is at $format. Run /playbook-wiki:migrate to bring it to that format." \
        "The wiki of this project is at wiki format $current, and the playbook is at $format. The person was shown this at the start of the session; recommend running the migrate skill (/playbook-wiki:migrate). Do not repair the wiki unasked."
    elif [ "$current" -gt "$format" ]; then
      notice "This project's wiki is at format $current, newer than the playbook's $format: the playbook installed is older than the wiki. Update its plugins with /plugin, then start a new session." \
        "The wiki of this project is at wiki format $current, newer than the wiki format $format of the playbook installed, so its plugins are older than the wiki. The person was shown this at the start of the session. Do not mark or migrate the wiki, and do not update a plugin unasked."
    fi
    exit 0 ;;
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
      printf 'FAIL %s has no README.md. Run this from the project'"'"'s root, or pass the folder of the wiki.\n' "$wiki" >&2
      exit 3
    fi
    if [ -L "$marker" ]; then
      printf 'FAIL %s is a symbolic link; replace it with a file. The marker was not written.\n' "$marker" >&2
      exit 3
    fi
    if ! sh "$check_wiki" --column "$wiki"; then
      printf 'FAIL %s/README.md has no column "Code it governs" in its table of pages, so the wiki is not at wiki format %s. Add the column as format.md says under "The project'"'"'s README.md". The marker was not written.\n' "$wiki" "$format" >&2
      exit 3
    fi
    # Keep the old marker, byte for byte, beside it, so a failed or interrupted
    # check can put it back. The wiki's folder must be writable for the marker
    # anyway; a temporary folder may not be. From here on, any exit deletes the
    # copy; from the first write to the end of the check, any exit that is not
    # a success also puts the old marker back, or removes the new one. An
    # interrupt is handled when the running check ends.
    saved="$marker.saved"
    had_marker=0
    armed=0
    undo() {
      if [ "$armed" = 1 ]; then
        armed=0
        if [ "$had_marker" = 1 ]; then cp "$saved" "$marker"; else rm -f "$marker"; fi
      fi
      rm -f "$saved" 2>/dev/null
    }
    trap undo EXIT
    trap 'exit 1' INT TERM HUP
    if ! rm -f "$saved" 2>/dev/null; then
      printf 'FAIL could not remove %s, left by an earlier run. Remove it by hand. The marker was not written.\n' "$saved" >&2
      exit 4
    fi
    if [ -f "$marker" ]; then
      had_marker=1
      if ! cp "$marker" "$saved"; then
        printf 'FAIL could not keep a copy of %s. Check that its folder can be written. The marker was not written.\n' "$marker" >&2
        exit 4
      fi
    fi
    armed=1
    if ! printf '%s\n' "$format" 2>/dev/null > "$marker"; then
      armed=0
      printf 'FAIL could not write %s. Check that its folder can be written. The marker was not written.\n' "$marker" >&2
      exit 4
    fi
    if ! sh "$check_wiki" "$wiki"; then
      undo
      printf 'The marker was not written. Repair what the check lists, then run mark again.\n' >&2
      exit 1
    fi
    armed=0
    undo
    trap - EXIT INT TERM HUP
    rm -f "$wiki/.unchecked-decisions"
    printf 'marked %s as wiki format %s\n' "$wiki" "$format" ;;
  -h|--help)
    printf '%s\n' "$usage" ;;
  *)
    printf '%s\n' "$usage" >&2
    exit 2 ;;
esac
