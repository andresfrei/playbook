# Definition of the work decision-index

## The problem

To know what is in force on a subject, an agent reads every work's `decisions.md` and guesses which decision replaced which: a replacement is written only in prose, such as "This replaces the Claude-only scope of D191". This repository holds 417 decisions in 24 works and 241 of history; the cost grows with every work, most in large repositories. In the review of 2026-11-20 this misled five agents into 79 false findings (decision-review-10).

## Today

- Each work writes its own `decisions.md`, appending rows, so parallel works never touch the same file. Kept (decision-review-10).
- 194 of the 417 rows name a shared page; the rest are closings of stages, plans, versions, and other steps.
- 33 rows say in prose that they replace or narrow another.
- `check-wiki.sh --decisions` prints every decision of every work, and checks nothing.
- At session start, `wiki-format.sh hook` tells the owner when the wiki is below the playbook's format and to run the doctor.

## What changes


- A column Replaces in a work's `decisions.md`: the identifiers of the decisions this one replaces, or empty. The check fails on an identifier that does not exist. Decided (decision-index-4).
- The area of a decision is its column Shared page, which already exists: the index lists by shared page, so "what is in force about installation" is the rows whose shared page is `03-technology/installation.md`. No column Area. Decided (decision-index-4).
- The index is printed, never written: `check-wiki.sh --decisions` gets `--in-force` and a shared page to filter by. A decision is in force when it names a shared page and no later decision replaces it.
- Format 6, released as 4.0.0 (decision-index-3). `playbook-wiki` reads and writes only the current format; the rules for older formats leave the check and `format.md`. A wiki below it is neither read nor written until the owner runs the migration, which brings any older wiki straight to the current format, filling Replaces from the prose where a row names what it replaces, and turning `docs/wiki/decisions.md` into a work of history (decision-index-2). This replaces the part of decision-review-10 that let an older wiki be read.

## What it must not do

- Write the index into a file: a written index goes stale.
- Keep any rule for a format older than the current one (decision-index-2).
