# adr-scaffold

A skill that bootstraps an Architecture Decision Records (ADR) folder structure — `docs/decisions/` — in a repository for the first time. One-time setup, not a per-decision workflow.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Checks whether `docs/decisions/` already exists — never overwrites it, shows what's there instead |
| 2 | Creates five files: `README.md` (guide + template + lifecycle), `INDEX.md` (active decisions table), `0001-example-adr.md` (worked example: Postgres vs. SQLite), `archive/README.md`, `archive/INDEX.md` |
| 3 | Summarizes what was created and the one rule to remember: specs win over ADRs when they disagree, and archived ADRs are never edited — corrections go in `archive/INDEX.md` |

The core idea it bakes in: **specs** (`docs/specs/`) are the source of truth for what the system does *today*; **ADRs** are the source of truth for *why* a past decision was made. Once implemented, a decision gets archived and frozen — its reasoning stays on record, but the spec it produced is what governs current behavior.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/adr-scaffold -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just ask, in your own words:

> "let's set up ADRs for this project"
> "I want to start documenting architecture decisions"
> "we need a docs/decisions folder"

## After bootstrapping

Replace `docs/decisions/0001-example-adr.md` with the team's first real decision (or delete it once a real one exists), keeping the `<NNN>-<slug>.md` naming scheme. From then on, just follow the repo's own `docs/decisions/README.md` directly — this skill's job is done once the structure exists.
