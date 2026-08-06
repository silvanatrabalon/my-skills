# review-pr-curate

Part of the [`review-pr`](../review-pr) suite — see that skill's README for the full end-to-end flow. The human gate between a local review and GitHub — decides which findings from `priorities.md` actually get posted.

**Requires a GitHub-hosted repo.** Uses `gh api .../pulls/<n>/comments` and `.../reviews` (read-only) to detect findings already raised by a bot or human reviewer.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Resolves the latest pass folder and parses `priorities.md` (Must Fix / Should Fix / Nits) |
| 2 | Fetches existing PR comments and auto-marks findings already raised by a bot or human reviewer as `covered-elsewhere` |
| 3 | Presents a checklist — Must Fix selected by default, Should Fix and Nits unselected — with `keep` / `keep + edit` / `drop` per finding |
| 4 | Writes `curated.json` in the pass folder, ready for `review-pr-post` |

Nits are never default-selected. Editing a finding's copy is tracked as `prose_drift` for later precision analysis.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-curate -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Run after `review-pr <n>` completes:

> "curate the review for PR 42"
> "which findings should we actually post?"

The agent walks through Must Fix / Should Fix / Nits, defaults sensibly, and writes `curated.json` for the next step.
