---
type: regex
target:
  source: file
  path: docs/wiki/works/pdf-invoice/plan.md
pattern: '(?m)^\|[^\n]*\bWaits for\b[^\n]*\|[ \t]*\n\|[ \t]*:?-{3,}:?[ \t]*(\|[ \t]*:?-{3,}:?[ \t]*)*\|[ \t]*$'
flags: i
---
