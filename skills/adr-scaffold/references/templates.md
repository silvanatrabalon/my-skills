# ADR scaffold — file templates

Copy each block below verbatim into the path given in its heading. Nothing here needs per-repo customization — it's already generic.

---

## `docs/decisions/README.md`

```markdown
# Decision Records

This folder contains Architecture Decision Records (ADRs) — short documents
that capture *why* a significant technical decision was made.

## Specs vs. ADRs — source of truth

**Specs** (`docs/specs/` or `specs/`) are the source of truth for *what* the
system does today — living behavior contracts, updated continuously.

**ADRs** are the source of truth for *why* a path was chosen — point-in-time
decision records. Once a decision is implemented and archived, the spec it
produced governs behavior, not the ADR.

**When a spec and an ADR disagree, the spec wins.** Cite specs in code
comments, PR descriptions, and design docs — not ADRs. If a stale ADR is
misleading, note the amendment in `archive/INDEX.md` — **never edit an
archived ADR directly.**

Use ADRs to recover *why*, not *what*:
- *"Why did we choose Postgres over MongoDB?"* → read the ADR.
- *"What must the database layer do today?"* → read the spec.

If a doc near its title says Frozen, Superseded, or Withdrawn, treat the body
as historical context only and follow any successor pointer in the banner.

---

## When to write an ADR

Write one when:

- You're choosing between two or more significantly different approaches
- The decision has long-term consequences (hard to reverse, affects many files)
- You want future contributors (or AI agents) to understand the reasoning
- A decision might look wrong without context

Don't write one for:
- Obvious choices with no real alternatives
- Style preferences (use lint rules instead)
- Decisions that will be revisited in days

---

## Format

Use the template below. Keep it short — a good ADR fits in one screen.

```markdown
# <NNN>. <Short imperative title>

**Date:** YYYY-MM-DD
**Status:** Draft | Accepted | Frozen | Superseded | Withdrawn

## Context

What is the problem or situation that forced this decision?
What constraints exist?

## Decision

What did we decide to do?

## Consequences

What becomes easier? What becomes harder?
What follow-up decisions does this create?

## Alternatives considered

What else did we evaluate and why did we reject it?
```

---

## Lifecycle

| Status | Meaning | Location |
|---|---|---|
| **Draft** | Being written | `docs/decisions/` |
| **Accepted** | Ratified and being implemented | `docs/decisions/` |
| **Frozen** | Implemented; promoted to a spec | `docs/decisions/archive/` |
| **Superseded** | Replaced by a later decision | `docs/decisions/archive/` |
| **Withdrawn** | Proposed but never accepted | `docs/decisions/archive/` |

When a decision is implemented:
1. `git mv docs/decisions/<n>-<slug>.md docs/decisions/archive/<n>-<slug>.md`
2. Add a **Frozen** banner below the title with a link to the spec it produced.
3. Add a row to `docs/decisions/archive/INDEX.md`.
4. Update any inbound links.

After archival the ADR is **not edited**. Amendments go in `archive/INDEX.md`.

---

## Naming convention

```
docs/decisions/<NNN>-<slug>.md
```

- `<NNN>` — zero-padded sequence number (0001, 0002, ...)
- `<slug>` — kebab-case summary (e.g. `choose-postgres-over-sqlite`)

---

## Index

| # | Title | Status | Date |
|---|---|---|---|
| [0001](0001-example-adr.md) | Example: choose Postgres over SQLite | Accepted | 2026-01-15 |
```

---

## `docs/decisions/INDEX.md`

```markdown
# Decisions Index

All active (non-archived) decision records.

| # | Title | Status | Date |
|---|---|---|---|
| [0001](0001-example-adr.md) | Example: choose Postgres over SQLite | Accepted | 2026-01-15 |

---

See `archive/INDEX.md` for implemented and superseded decisions.
```

---

## `docs/decisions/0001-example-adr.md`

```markdown
# 0001. Choose Postgres over SQLite for persistent storage

**Date:** 2026-01-15
**Status:** Accepted

---

> This is an **example ADR**. Replace it with your first real decision.
> See `README.md` for format guidance and lifecycle rules.

---

## Context

We need a persistent relational database for the API layer. The two realistic
options for our team size and workload are SQLite (embedded, zero ops) and
Postgres (server-based, production-grade).

Constraints:
- We expect concurrent writes from multiple API instances behind a load balancer.
- We'll need full-text search within 6 months.
- The team has strong Postgres experience.

## Decision

Use **Postgres 16** hosted on a managed cloud service (e.g. AWS RDS, Supabase,
Railway).

## Consequences

**Easier:**
- Horizontal scaling — multiple API instances can connect concurrently.
- Full-text search via `tsvector` when needed.
- Standard tooling: migrations with `golang-migrate` or `alembic`, backups via
  provider.

**Harder:**
- Local development requires running Postgres (use Docker Compose).
- No zero-ops option — managed service cost and ops overhead.

## Alternatives considered

**SQLite:** Ideal for single-server setups or CLIs. Rejected because WAL mode
doesn't support multiple concurrent writer processes across machines.

**MySQL/MariaDB:** Viable but team has no experience. Standard SQL compatibility
differences add friction. No clear advantage over Postgres for our use case.
```

---

## `docs/decisions/archive/README.md`

```markdown
# Decisions Archive

Implemented, superseded, and withdrawn decision records.

**These files are frozen — never edited after archival.**
Amendments and corrections go in `INDEX.md` below, not in the ADR body.

See the parent `docs/decisions/README.md` for the full lifecycle rules.

---

See `INDEX.md` in this folder for the full table.
```

---

## `docs/decisions/archive/INDEX.md`

```markdown
# Archive Index

Implemented (Frozen), Superseded, and Withdrawn decision records.

| # | Title | Status | Archived | Notes / Amendments |
|---|---|---|---|---|
| — | — | — | — | No archived decisions yet |

---

## Amendment format

When a frozen ADR is found to be misleading or partially wrong, add a row here
instead of editing the archived file:

| 0001 | Choose Postgres over SQLite | Frozen | 2026-03-01 | **Amendment 2026-06-15:** The `read_replicas` approach documented in the ADR was superseded by PgBouncer pooling — see `docs/specs/database.md`. |
```
