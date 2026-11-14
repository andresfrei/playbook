---
tags: [keep-minimal]
allowed_tools: [Read, Glob, Grep, Skill]
---

Review this change for unnecessary complexity. The task was to show a price stored in cents as dollars in one place, the invoice page. The change adds a `Formatter` interface, a `PriceFormatter` class that implements it, a `FormatterFactory` that returns that class, a `currency` option that only ever receives "USD", and the `money-format` npm package. Tell me what is more than the task needs.
