# review-pr

A skill that orchestrates a multi-phase, multi-specialist PR review — entirely local, no GitHub comments posted automatically. Any tech stack, but **requires a GitHub-hosted repo** — it reads the PR via `gh pr view` / `gh pr diff` / `gh api .../pulls/<n>/files`. It does not work against GitLab, Bitbucket, or Azure DevOps PRs.

This is the biggest and most sophisticated skill in this repo. It's **not one skill** — it's four, meant to be installed together and used in sequence, one per stage of the review lifecycle:

| # | Skill | Depends on `gh`? | What it does |
|---|---|---|---|
| 1 | `review-pr` | Yes (read-only) | Runs the multi-specialist review, writes `priorities.md` locally |
| 2 | [`review-pr-curate`](../review-pr-curate) | Yes (read-only) | You pick which findings actually get posted |
| 3 | [`review-pr-post`](../review-pr-post) | Yes (writes comments) | Publishes the curated findings to GitHub |
| 4 | [`review-pr-close`](../review-pr-close) | **No** — pure local bookkeeping | Records what happened to each finding, feeds precision tracking back into step 1 |

This README covers `review-pr` itself and the end-to-end flow — see each skill's own README for its specifics.

---

## What It Does

| Concept | How it works |
|---|---|
| **Self-contained specialists** | Six specialist role definitions (`code-reviewer`, `security-auditor`, `test-reviewer`, `performance-reviewer`, `a11y-auditor`, `challenger`) live in `references/agents/` and get injected as the full prompt of a general-purpose subagent — no separate agent-registration step needed after install |
| **Profiles** | `spike` (title `wip:`/`spike:`) → code-reviewer only; `feature` (default) → code gate + risk-gated outliers; `release` (merge to main, version bump, `hotfix:`) → full roster |
| **Risk-surface detection** | Deterministic, no LLM: scans the diff for `interactive-ui`, `auth-security`, `data-fetching` patterns to decide which outlier specialists unlock |
| **Two sequential phases** | Phase 1 (code gate: code-reviewer + test-reviewer) always finishes before Phase 2 (outliers) starts, so outliers get code-gate context |
| **Challenger pass** | An adversarial specialist reviews the triaged findings and can only KEEP / WEAKEN / DROP — reduces false positives and severity inflation, with a same-family pass and an optional cross-family pass on a different model |
| **Output budget** | Should Fix / Nits are capped by profile × PR-size multiplier; Must Fix is never capped; overflow goes to a collapsed section in `challenger.md`, never silently deleted |
| **Precision tracking** | `review-pr-close` feeds `.signal-ratios.json` and `.specialist-retention.json`, which `review-pr` reads back to warn (not auto-suppress) when a specialist's real-world precision drops |

Output lands in `docs/reviews/pr-<n>-review-<reviewer>-pass-<n>/`: `priorities.md` (start here), `challenger.md`, and `specialists/<name>.md` per specialist that ran.

---

## Prerequisites

- [`gh` CLI](https://cli.github.com/) authenticated (`gh auth status`)
- Working directory inside the target repo (or a full `{owner}/{repo}#<n>` reference)
- The Agent tool available for subagent fan-out

Optional but recommended: copy `references/review-md-template.md` to the target repo's root as `REVIEW.md` and fill in project context, suppressed categories, and touch-density gates. Without it, `review-pr` proceeds with defaults.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/review-pr -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Each of the four skills triggers on natural language, not a slash command — the agent recognizes intent from what you say, same as every other skill in this repo. A full pass through the suite looks like this:

**1. Install all four:**

```bash
npx skills add github:silvanatrabalon/my-skills/skills/review-pr -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-curate -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-post -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/review-pr-close -a claude-code
```

Only installing `review-pr` on its own is fine too, if you never plan to publish findings automatically — it's still useful as a read-only local review.

**2. Run the review** — triggers `review-pr`:

> "review PR 42"
> "run review-pr on this branch"

Identifies the PR, resolves a profile (spike/feature/release), spawns the right specialists in two phases, runs the challenger pass, and writes `docs/reviews/pr-42-review-<you>-pass-1/priorities.md`. **Nothing is posted to GitHub at this stage.**

**3. Pick what to publish** — triggers `review-pr-curate`:

> "curate the review for PR 42"
> "which findings should we post?"

Presents the Must Fix / Should Fix / Nits checklist (Must Fix selected by default), lets you keep, edit, or drop each one, and writes `curated.json`.

**4. Publish** — triggers `review-pr-post`:

> "post the curated review"
> "publish the findings we selected"

Posts inline comments + a review summary to GitHub. Safe to re-run — it skips anything already posted.

**5. (Optional) Close the loop, once the PR is merged** — triggers `review-pr-close`:

> "close out the review for PR 42"

Asks what actually happened to each Must Fix / Should Fix finding (fixed? dismissed? deferred?) and records it locally — this is what lets `review-pr` warn you next time a specialist's real-world precision has dropped.

---

## Reference files

- `references/agents/*.md` — the six specialist role definitions.
- `references/priorities-template.md` — the `priorities.md` rendering template.
- `references/review-md-template.md` — copy to a repo's root as `REVIEW.md` to tune specialist behavior.
- `references/bugbot-template.md` — copy to a repo's root as `BUGBOT.md`, a human-judgment review checklist.
