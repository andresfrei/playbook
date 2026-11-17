#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
# Builds a repository whose last commit shows a price stored in cents as
# dollars on the invoice page, with more than that task needs: an interface,
# a class, a factory, an option that only receives "USD", and a package.
mkdir -p src
cat > package.json <<'JSON'
{
  "name": "billing",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {}
}
JSON
cat > src/invoice.ts <<'TS'
export function invoiceLine(item: { name: string; priceCents: number }): string {
  return `${item.name}: ${item.priceCents}`;
}
TS
git add -A
git commit -q -m "feat: invoice page"

cat > package.json <<'JSON'
{
  "name": "billing",
  "version": "1.0.0",
  "type": "module",
  "dependencies": { "money-format": "^2.1.0" }
}
JSON
cat > src/formatter.ts <<'TS'
import moneyFormat from "money-format";

export interface Formatter {
  format(cents: number): string;
}

export class PriceFormatter implements Formatter {
  constructor(private readonly options: { currency: string }) {}

  format(cents: number): string {
    return moneyFormat(cents / 100, { currency: this.options.currency });
  }
}

export class FormatterFactory {
  static create(options: { currency: string } = { currency: "USD" }): Formatter {
    return new PriceFormatter(options);
  }
}
TS
cat > src/invoice.ts <<'TS'
import { FormatterFactory } from "./formatter.js";

const formatter = FormatterFactory.create({ currency: "USD" });

export function invoiceLine(item: { name: string; priceCents: number }): string {
  return `${item.name}: ${formatter.format(item.priceCents)}`;
}
TS
git add -A
git commit -q -m "feat: show invoice prices in dollars"
