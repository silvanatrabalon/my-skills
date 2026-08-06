# priorities.md template

The orchestrator renders **`priorities.md`** inside each pass folder using this layout.
Per-specialist raw output lives in `specialists/<name>.md`.
Challenger ledger lives in `challenger.md`.

Replace all `<placeholders>`. Use HTML `<details>` for collapsible sections.

---

```markdown
# PR #<number> Review — <title>

## Metadata

| Field | Value |
|---|---|
| **PR** | [#<number>](<pr-url>) |
| **Author** | <author login> |
| **Head SHA** | `<short-sha>` ([full](<commit-url>)) |
| **Branch** | `<headRefName>` → `<baseRefName>` |
| **Tracker ref** | [<key>](<tracker-url>) or N/A |
| **Human reviewer** | <display-name> (`<reviewer-slug>`) |
| **Review pass** | <pass> |
| **Profile** | `<profile>` — <profile_reason> |
| **Date** | <YYYY-MM-DD> |
| **Specialists active** | <comma-separated list> |
| **Specialists skipped** | <list with reason, or "none"> |
| **Risk surfaces** | <interactive-ui, auth-security, data-fetching, ... or "none"> |
| **Budget** | SF cap <n> / Nits cap <n> (base <profile> × <multiplier> for <file-count> files) |
| **Signal ratio** | <(MF+SF)/(MF+SF+Nits) %> |
| **Verdict** | <approve \| comments \| request-changes> |

---

## TL;DR

| | |
|---|---|
| **Verdict** | <approve \| comments \| request-changes> |
| **Must fix** | <count after challenger> |
| **Should fix** | <count after budget> |
| **Nits** | <count after budget> |
| **Summary** | <one sentence> |
| **Reconciliation** | <pass ≥ 2 only> |

---

## Reconciliation

*(Include only when pass ≥ 2.)*

| Prior ID | Prior severity | Status | Verified by | Note |
|---|---|---|---|---|
| MF-1 | Critical | fixed | code-reviewer | ... |

---

## Counts

| Severity | Rendered | Pre-budget | Overflow |
|---|---|---|---|
| Must fix (Critical) | | | — |
| Should fix (Warning) | | | <n if any> |
| Nits (Info) | | | <n if any> |

### By specialist

| Specialist | Critical | Warning | Info |
|---|---|---|---|
| pre-flight | | | |
| code-reviewer | | | |
| test-reviewer | | | |
| security-auditor | | | |
| performance-reviewer | | | |
| a11y-auditor | | | |

### Specialist retention (post-challenger)

| Specialist | Emitted | Retained | Retain rate |
|---|---|---|---|
| code-reviewer | | | |
| ... | | | |

*(Also written to `retention.json` in this pass folder.)*

---

## Must Fix (Critical)

*(Sort: security, bug, test-gap, complexity; tie-break file path.)*

### MF-<n>. <title> `category:<cat>` `carried-forward` *(if applicable)*

| | |
|---|---|
| **File** | `<path>#L<line>` |
| **Confidence** | High \| Medium \| Low |
| **Specialists** | <list> |
| **Rationale** | <why> |
| **Severity rationale** | <why this severity, not adjacent tier> |
| **Fix** | <concrete action> |

---

## Should Fix (Warning)

### SF-<n>. <title> ...

| | |
|---|---|
| **File** | `<path>#L<line>` |
| **Confidence** | High \| Medium \| Low |
| **Specialists** | <list> |
| **Rationale** | <why> |
| **Fix** | <concrete action> |

---

<details>
<summary>Nice to Have / Nits (Info) — <count> items</summary>

*(Sorted by file path. Budget may truncate — see challenger.md overflow.)*

### N-<n>. <title> — `<path>#L<line>`

<rationale>

</details>

---

*Local review only — produced by review-pr orchestrator. Raw specialist output: `specialists/`. Challenger ledger: `challenger.md`. No GitHub comments posted.*
```

## Rendering rules

1. **Finding IDs** — `MF-*`, `SF-*`, `N-*`.
2. **request-changes** requires ≥1 Critical **after** challenger filtering.
3. **Dropped findings** — only in `challenger.md`, not in Must/Should/Nits.
4. **Budget overflow** — only in `challenger.md` under **Budget overflow**.
5. **Pass 1** — omit Reconciliation section and TL;DR reconciliation line.
6. **No per-specialist appendix** in `priorities.md` — use `specialists/` folder.
