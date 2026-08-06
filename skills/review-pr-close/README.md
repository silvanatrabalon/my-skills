# review-pr-close

Part of the [`review-pr`](../review-pr) suite — see that skill's README for the full end-to-end flow. Closes the feedback loop after a PR is merged or a review session ends — optional, but it's what makes `review-pr`'s trust-erosion alarms and precision tracking real instead of theoretical.

**The one skill in the suite that does not call `gh` at all.** It only reads the local `priorities.md`/`curated.json` and writes a local `.signal-ratios.json` — no GitHub API calls, so it works the same regardless of where the PR is hosted.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Loads the latest `priorities.md` and, if present, `curated.json` (for `prose_drift`) |
| 2 | For each Must Fix / Should Fix finding, records an outcome: `acted`, `acted-with-drift`, `dismissed`, `deferred`, or `covered-elsewhere` |
| 3 | Maps each finding's category to a precision tier (security/bug = Tier 1, target ≥90%; complexity/test-gap/performance/a11y/convention = Tier 2, ≥60%; style/nit = Tier 3) |
| 4 | Appends a record to `docs/reviews/.signal-ratios.json` (gitignored, append-only) |
| 5 | Prints per-specialist precision for this PR and the rolling last-5, flagging any specialist approaching the trust-erosion threshold |

Never blocks a merge — this is bookkeeping, not a gate.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-close -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Run after a PR is merged or the review session is done:

> "close out the review for PR 42"
> "record the outcomes on this review"

The agent walks through each Must Fix / Should Fix finding, records what actually happened, and reports precision trends per specialist.
