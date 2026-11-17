#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository whose own rules (AGENTS.md) require a pass-through
# wrapper and a date library, with a staged change that follows them and adds
# one real excess: an unused parameter.
mkdir -p src test
cat > AGENTS.md <<'MD'
# Project rules

- Every exported function in src/ runs inside audit(), even when it only calls one thing. Compliance asks for the log.
- Dates are handled with dayjs, never with Date.
MD
cat > package.json <<'JSON'
{
  "name": "shop-reports",
  "version": "1.0.0",
  "type": "module",
  "dependencies": { "dayjs": "^1.11.10" }
}
JSON
cat > src/audit.js <<'JS'
export function audit(action, fn) {
  console.log(`audit: ${action}`);
  return fn();
}
JS
git add -A
git commit -q -m "chore: audit helper"

cat > src/reports.js <<'JS'
import dayjs from "dayjs";
import { audit } from "./audit.js";

export function monthlyTotal(orders, month, locale = "en") {
  return audit("monthlyTotal", () =>
    orders
      .filter((o) => dayjs(o.date).format("YYYY-MM") === month)
      .reduce((sum, o) => sum + o.amount, 0),
  );
}
JS
cat > test/reports.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { monthlyTotal } from "../src/reports.js";

test("monthlyTotal sums the orders of the month", () => {
  const orders = [
    { date: "2026-10-03", amount: 10 },
    { date: "2026-10-20", amount: 5 },
    { date: "2026-11-01", amount: 99 },
  ];
  assert.equal(monthlyTotal(orders, "2026-10"), 15);
});
JS
git add -A
