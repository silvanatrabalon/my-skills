---
name: review-pr-curate
description: Curate a local PR review before posting to GitHub. Reads priorities.md from the latest pass folder, presents selectable findings, detects bot/human coverage, writes curated.json. Use when review-pr has just finished and the user wants to select which findings to publish. Not for the initial review itself (review-pr) or for posting (review-pr-post).
---

# review-pr-curate — select findings to post

**Audience:** Anyone who just ran `review-pr` and needs to decide what actually gets posted to GitHub.

**Goal:** Be the human gate between a local review and GitHub — nothing gets published without going through this selection step first.

Human gate between local review and GitHub. **Only `priorities.md` drives the
curated set**; consult `specialists/` or `challenger.md` for context on "why".

## Prerequisites

- Latest pass folder exists: `docs/reviews/pr-<n>-review-<reviewer>-pass-<p>/`
- `gh` authenticated
- `review-pr <n>` was completed (or pass folder exists from a prior run)

## Step 1 — Resolve pass folder

1. Resolve reviewer slug (same rules as `review-pr`: override or `gh api user`).
2. Glob `docs/reviews/pr-<n>-review-<reviewer>-pass-*/`.
3. Use **max pass** unless user specifies `pass:<p>`.

Read `priorities.md`. Parse Must Fix, Should Fix, Nits with finding IDs.

## Step 2 — Detect already-covered findings

Detect the current repo:

```bash
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
```

Fetch existing PR comments:

```bash
gh api repos/$REPO/pulls/<n>/comments --paginate
gh api repos/$REPO/pulls/<n>/reviews
```

Auto-mark local findings as **covered** when:

- Inline comment on same `file:line` (±2 lines) with similar rationale, or
- Bot author (Bugbot, Cursor, Copilot, `github-actions`) already flagged same issue, or
- Human reviewer comment matches finding theme

Covered findings default to **drop** in curation UI with note `covered-elsewhere`.

## Step 3 — Present checklist

Interactive selection (or structured summary if non-interactive):

| Finding | Default | Notes |
|---|---|---|
| Must Fix (`MF-*`) | **selected** | |
| Should Fix (`SF-*`) | unselected | |
| Nits (`N-*`) | unselected | never default-selected |

Per finding actions: `keep` | `keep + edit copy` | `drop`.

When user edits copy, store:

- `original_rationale`
- `edited_rationale`
- `prose_drift` — token-level diff score (simple word Jaccard or Levenshtein ratio)

## Step 4 — Write curated.json

Path: `docs/reviews/pr-<n>-review-<reviewer>-pass-<p>/curated.json`

Populate `display_name` from `gh api user --jq '.name'` (first token).

```jsonc
{
  "pr": 42,
  "pass": 1,
  "reviewer_slug": "alice",
  "display_name": "Alice",
  "head_sha": "abc1234",
  "priorities_path": "docs/reviews/pr-42-review-alice-pass-1/priorities.md",
  "created_at": "2026-01-15T10:00:00Z",
  "findings": [
    {
      "id": "MF-1",
      "severity": "Critical",
      "action": "keep",
      "post_inline": true,
      "file": "src/auth/session.ts",
      "line": 47,
      "body": "<rationale + fix for GitHub>",
      "prose_drift": null,
      "covered_elsewhere": false
    }
  ]
}
```

## Step 5 — Print summary

- Path to `curated.json`
- Count: selected for inline, selected for summary-only, dropped, covered-elsewhere
- Next step: `review-pr-post <n>`

## Guardrails

- Never post to GitHub from this skill
- Nits never default-selected
- Idempotent re-curate overwrites `curated.json` for same pass
