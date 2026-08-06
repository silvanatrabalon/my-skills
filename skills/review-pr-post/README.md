# review-pr-post

Part of the [`review-pr`](../review-pr) suite — see that skill's README for the full end-to-end flow. Publishes exactly what was curated in `curated.json` — inline comments for Must Fix, a summary review for Should Fix — and nothing else.

**Requires a GitHub-hosted repo.** Writes directly to it via `gh api .../pulls/<n>/comments` and `gh pr review` — this is the one skill in the suite that actually posts.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Loads `curated.json` from the latest pass folder — refuses to run without it |
| 2 | Checks `posted_comment_ids` so re-running never double-posts (unless `force:true`) |
| 3 | Posts inline comments via `gh api`, each ending in an attribution footer naming the human reviewer |
| 4 | Posts one PR review summary (`gh pr review --comment`) with Must Fix listed and Should Fix collapsed |
| 5 | Updates `curated.json` with `posted_at`, `posted_sha`, and the comment IDs |

Nits are never posted unless explicitly selected during curation.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-post -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Run after `review-pr-curate <n>` completes:

> "post the curated review for PR 42"
> "publish the findings we selected"

The agent posts inline comments and a summary review to GitHub, with an idempotency check so it's safe to run twice.
