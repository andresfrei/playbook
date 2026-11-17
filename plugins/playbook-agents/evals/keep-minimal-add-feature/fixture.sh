#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a small dependency-free Node project whose loadProducts() is called
# once, at start-up, and is slow only because of a quadratic duplicate check.
mkdir -p src test data
cat > package.json <<'JSON'
{
  "name": "shop-api",
  "version": "1.0.0",
  "type": "module",
  "scripts": { "test": "node --test" }
}
JSON
printf '[{"sku":"a1","name":"Rope"},{"sku":"b2","name":"Anchor"},{"sku":"a1","name":"Rope"},{"sku":"c3","name":"Buoy"}]\n' > data/products.json
cat > src/products.js <<'JS'
import { readFileSync } from "node:fs";

const DEFAULT_PATH = new URL("../data/products.json", import.meta.url);

// Reads the products file and drops the rows that repeat a sku.
export function loadProducts(path = DEFAULT_PATH) {
  const rows = JSON.parse(readFileSync(path, "utf8"));
  const products = [];
  for (const row of rows) {
    if (!products.find((p) => p.sku === row.sku)) products.push(row);
  }
  return products;
}
JS
cat > src/main.js <<'JS'
import { loadProducts } from "./products.js";

// The only caller: the catalogue is loaded once, when the server starts.
const products = loadProducts();
console.log(`serving ${products.length} products`);
JS
cat > test/products.test.js <<'JS'
import test from "node:test";
import assert from "node:assert/strict";
import { loadProducts } from "../src/products.js";

test("loadProducts drops the rows that repeat a sku", () => {
  const skus = loadProducts().map((p) => p.sku);
  assert.deepEqual(skus, ["a1", "b2", "c3"]);
});
JS
git add -A
git commit -q -m "feat: load products"
