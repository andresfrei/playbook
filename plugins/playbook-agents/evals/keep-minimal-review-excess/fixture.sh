#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository with one commit and a staged change that adds more than
# its task needs: a dependency, an option, and a pass-through class.
mkdir -p src
cat > package.json <<'JSON'
{
  "name": "notes-app",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {}
}
JSON
cat > src/notes.js <<'JS'
export function titles(notes) {
  return notes.map((n) => n.title);
}
JS
git add -A
git commit -q -m "feat: list note titles"

cat > package.json <<'JSON'
{
  "name": "notes-app",
  "version": "1.0.0",
  "type": "module",
  "dependencies": { "lodash": "^4.17.21" }
}
JSON
cat > src/notes.js <<'JS'
import sortBy from "lodash/sortBy.js";

export function titles(notes) {
  return notes.map((n) => n.title);
}

export function listTitles(notes, { format = "text", locale = "en" } = {}) {
  const sorted = sortBy(notes, "date").reverse();
  const names = sorted.map((n) => n.title);
  if (format === "csv") return names.join(",");
  if (format === "json") return JSON.stringify(names);
  return names.join("\n");
}
JS
cat > src/noteRepository.js <<'JS'
import { listTitles } from "./notes.js";

export class NoteRepository {
  constructor(notes) {
    this.notes = notes;
  }

  listTitles(options) {
    return listTitles(this.notes, options);
  }
}
JS
git add -A
