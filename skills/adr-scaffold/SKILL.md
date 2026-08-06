---
name: adr-scaffold
description: Bootstrap an Architecture Decision Records (ADR) folder structure (docs/decisions/) in a repository for the first time, with a worked example, an index, and an archive lifecycle. Use when the user asks to set up ADRs, wants to start documenting architecture decisions, or references docs/decisions/ in a repo that doesn't have it yet. Not for writing an individual ADR in a repo that already has this structure — just follow the existing README.md template directly.
---

# ADR Scaffold

**Audience:** Someone setting up architecture decision records in a repo that doesn't have them yet.

**Goal:** Leave the repo with a working `docs/decisions/` structure — guide, index, one worked example, and an archive lifecycle — so the very next real decision has somewhere to go and a template to follow.

This is a **one-time bootstrap**. It does not write the team's first real ADR for them (past the worked example) and does not implement anything else.

## Step 1 — Check for an existing structure

Look for `docs/decisions/` at repo root. If it already exists, **don't overwrite it** — show what's there (existing ADRs, current `INDEX.md`) and ask how to proceed instead of imposing this structure on top of it.

## Step 2 — Create the structure

If it doesn't exist, create these five files exactly as given in `references/templates.md`:

- `docs/decisions/README.md` — the guide: when to write an ADR, the template, the lifecycle table, and the source-of-truth rule against specs.
- `docs/decisions/INDEX.md` — table of active (non-archived) decisions, starting with the worked example.
- `docs/decisions/0001-example-adr.md` — a real worked example (Postgres vs. SQLite) so the format is unambiguous from day one.
- `docs/decisions/archive/README.md` — explains the archive is frozen; corrections go in `archive/INDEX.md`, never in the archived file itself.
- `docs/decisions/archive/INDEX.md` — empty archive table plus the amendment-format example.

Copy the content verbatim from `references/templates.md` — it's already generic and doesn't need per-repo customization.

## Step 3 — Final summary

Tell the user:

- The five files created and their paths.
- The core rule to remember: **specs are the source of truth for what the system does today; ADRs are the source of truth for why a past decision was made.** When they disagree, the spec wins — never edit an archived ADR, amend via `archive/INDEX.md` instead.
- The next concrete step: replace `0001-example-adr.md` with the team's first real decision (or delete it once a real ADR exists), keeping the same numbering scheme (`<NNN>-<slug>.md`).

## When someone later asks you to write a real ADR

Read the repo's own `docs/decisions/README.md` (not this skill) and follow its template and lifecycle rules directly — this skill's job ends once the structure exists.

## Reference files

- `references/templates.md` — full content for all five bootstrapped files.
