#!/bin/bash
# The seeded diff "language": drops the checks on the language of init.sh.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
exec bash "$here/../seeds/build.sh" "$here/../seeds/language" 753e158 \
  "feat(init): accept a language written with any character" "$@"
