#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository with one commit and an uncommitted change whose
# pageCount drops the last partial page.
mkdir -p src test
cat > src/pagination.js <<'JS'
// Pagination helpers. Pages are numbered from 1.

export function paginate(items, page, size) {
  const start = (page - 1) * size;
  return items.slice(start, start + size);
}
JS
cat > test/pagination.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { paginate } from "../src/pagination.js";

test("paginate returns the second page", () => {
  assert.deepEqual(paginate([1, 2, 3, 4, 5], 2, 2), [3, 4]);
});
JS
git add -A
git commit -q -m "feat: paginate"

cat >> src/pagination.js <<'JS'

// How many pages are needed to show every item.
export function pageCount(items, size) {
  return Math.floor(items.length / size);
}
JS
