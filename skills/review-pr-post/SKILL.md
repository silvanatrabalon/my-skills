---
name: review-pr-post
description: Post curated PR review findings to GitHub. Reads curated.json from the latest pass folder; inline Must Fix by default; summary body for Should Fix. Appends LLM attribution footer. Use when review-pr-curate has just finished and the user wants to publish the selected findings. Not for selecting findings (review-pr-curate) or running the review itself (review-pr).
---

# review-pr-post — publish curated review to GitHub

**Audience:** Anyone who just ran `review-pr-curate` and is ready to actually publish the selected findings.

**Goal:** Post exactly what was curated — nothing more — as inline comments and a review summary, with idempotent re-runs and clear attribution.

Posts human-curated findings from `review-pr-curate`. **Never run without
`curated.json`.**

## Prerequisites

- `curated.json` in latest pass folder for PR `<n>`
- `gh` authenticated with permission to comment on the repo

## Step 1 — Load curated.json

Resolve pass folder (same as curate skill). Read `curated.json`.

If missing, tell user to run `review-pr-curate <n>` first.

Detect the current repo:

```bash
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')
```

## Step 2 — Idempotency check

For each finding with `post_inline: true`, check `posted_comment_ids` in
`curated.json`. Skip findings already posted unless user passes `force:true`.

```bash
gh api repos/$REPO/pulls/<n>/comments --paginate
```

Match by finding `id` stored in comment body footer or tracked IDs.

## Step 3 — Post inline comments

For each selected finding with `post_inline: true`:

```bash
gh api repos/$REPO/pulls/<n>/comments \
  -f body="<body>" \
  -f commit_id="<head_sha from curated.json>" \
  -f path="<file>" \
  -F line=<line>
```

**Body must end with attribution footer** — use `display_name` from `curated.json`.
Do not hardcode a name.

```
---

Posted by an LLM on behalf of <display_name>, let them know if anything seems off.
```

Include finding id in body for idempotency: `<!-- review:MF-1 -->`

## Step 4 — Post review summary

Submit one PR review with event `COMMENT`:

- Inline-posted Must Fix listed briefly
- Should Fix as collapsed markdown list (not inline unless `post_inline: true`)
- Nits omitted unless explicitly curated with `post_inline: true`

Same footer on review body.

```bash
gh pr review <n> --comment --body "<summary>"
```

## Step 5 — Update curated.json

Record:

```jsonc
{
  "posted_at": "2026-01-15T11:00:00Z",
  "posted_sha": "<head_sha>",
  "posted_comment_ids": ["123456", "123457"]
}
```

## Guardrails

- Never auto-post from orchestrator
- Nits never posted unless explicitly selected in curate step
- Re-post skips already-posted finding ids
- Always append LLM attribution footer
