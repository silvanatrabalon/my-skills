---
name: review-pr-close
description: Close the feedback loop on a local PR review. Records acted/dismissed outcomes per finding into docs/reviews/.signal-ratios.json for precision tracking and trust-erosion alarms. Use when a reviewed PR has just merged or the review session is complete and the user wants to record what happened to each finding. Not for the review itself, curation, or posting.
---

# review-pr-close — signal-ratio feedback loop

**Audience:** Anyone closing out a reviewed PR who wants the review suite to actually get better over time.

**Goal:** Record what happened to each finding after the fact, so `review-pr`'s trust-erosion alarms and monthly precision audits have real data instead of guesses.

Optional step after PR merge or review session. Feeds `review-pr` trust-erosion
alarms and monthly precision audits.

## Prerequisites

- Pass folder with `priorities.md` for PR `<n>`
- User can classify outcomes for Must Fix / Should Fix findings

## Step 1 — Load context

Read latest `priorities.md` from pass folder. Parse `MF-*` and `SF-*` findings.
Read metadata: profile, specialists active, head SHA.

If `curated.json` exists, import `prose_drift` from edited findings.

## Step 2 — Prompt per finding

For each Must Fix / Should Fix id, collect:

| Outcome | Meaning |
|---|---|
| `acted` | Author fixed, or user agreed and tracked a follow-up |
| `acted-with-drift` | Directionally right but reviewer edited prose in curate (high `prose_drift`) |
| `dismissed` | Not actionable — capture optional `dismiss_reason` |
| `deferred` | Valid but intentionally postponed |
| `covered-elsewhere` | Another bot or human reviewer already raised it |

Auto-suggest `covered-elsewhere` when curate marked `covered_elsewhere: true`.

## Step 3 — Tier mapping

| Category | Tier |
|---|---|
| `security`, `bug` | Tier 1 (target precision ≥ 90%) |
| `complexity`, `test-gap`, `performance`, `a11y`, `convention` | Tier 2 (≥ 60%) |
| `style`, `nit` | Tier 3 (noise) |

## Step 4 — Append to .signal-ratios.json

Path: `docs/reviews/.signal-ratios.json` (gitignored). Create array if missing.

```jsonc
{
  "pr": 42,
  "profile": "feature",
  "head_sha": "abc1234",
  "closed_at": "2026-01-16",
  "specialists_active": ["code-reviewer", "test-reviewer", "security-auditor"],
  "findings": [
    {
      "id": "MF-1",
      "specialists": ["security-auditor"],
      "outcome": "acted",
      "prose_drift": 0.08,
      "category": "security",
      "tier": 1
    },
    {
      "id": "SF-3",
      "specialists": ["test-reviewer"],
      "outcome": "dismissed",
      "dismiss_reason": "covered by existing integration test",
      "category": "test-gap",
      "tier": 2
    }
  ]
}
```

Cross-reference `specialists/<name>.md` for per-specialist attribution when a
finding lists multiple specialists.

## Step 5 — Print aggregation hint

Show per-specialist precision for this PR and rolling last-5 for profile:

```
precision = (acted + acted-with-drift) / (acted + acted-with-drift + dismissed + deferred)
```

Note if any specialist would trigger trust-erosion alarm (< 40% over 5 PRs):

```
security-auditor: 2/3 acted this PR (67%). Rolling last-5 for feature: 45% — above threshold.
test-reviewer:    1/2 acted this PR (50%). Rolling last-5 for feature: 35% — approaching threshold (< 40%).
```

## Guardrails

- Optional — never block merge
- Append-only JSON (do not rewrite history)
- Nits outcomes optional (skip unless user wants full audit)
