#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Marta Ruiz"
# Builds a repository with a wiki (owner: Marta Ruiz) whose last commit adds
# summarize(). For an empty list it returns NaN and -Infinity, and the wiki
# decides that a day with no orders reads as zeros. The working tree is clean.
mkdir -p src test docs/wiki
cat > docs/wiki/README.md <<'MD'
# Orders wiki

Project owner: Marta Ruiz.

Every statement is Decided (numbered in [decisions.md](decisions.md)), Proposed, or Open.

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [decisions.md](decisions.md) | Numbered decisions with the owner's words | |
| [report.md](report.md) | What the daily order report shows | `src/report.js` |
MD
cat > docs/wiki/decisions.md <<'MD'
# Decisions

| ID | Date | Decision | Owner's words |
|----|------|----------|---------------|
| D1 | 2026-11-10 | The daily order report shows count, total, average, and largest order. | "the report has the count, the total, the average and the largest order of the day" |
| D2 | 2026-11-10 | A day with no orders reads as zeros in every field of the report. It never shows NaN or Infinity. | "if there were no orders, the report says zero everywhere, never NaN" |
MD
cat > docs/wiki/report.md <<'MD'
# Daily order report

- `summarize(orders)` returns `{ count, total, average, largest }` for the orders of one day (D1).
- A day with no orders returns zero in every field (D2).
MD
git add -A
git commit -q -m "docs: wiki of the order report"

cat > src/report.js <<'JS'
// Daily order report.

export function summarize(orders) {
  const amounts = orders.map((o) => o.amount);
  const total = amounts.reduce((a, b) => a + b, 0);
  return {
    count: amounts.length,
    total,
    average: total / amounts.length,
    largest: Math.max(...amounts),
  };
}
JS
cat > test/report.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { summarize } from "../src/report.js";

test("summarize reports a day with orders", () => {
  assert.deepEqual(summarize([{ amount: 10 }, { amount: 20 }]), {
    count: 2,
    total: 30,
    average: 15,
    largest: 20,
  });
});
JS
git add -A
git commit -q -m "feat: add summarize"
