# investigate-ci-failure

A skill that turns a red CI check into a short root-cause summary with `file:line` citations — instead of the agent dumping raw log output into the chat. Covers GitHub Actions, Jenkins, and CircleCI/other CI systems.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Identifies the failing check — from a PR number (`gh pr checks`) or a pasted CI URL |
| 2 | Fetches the log — `gh run view --log-failed` (GitHub Actions), `/consoleText` (Jenkins), or copy from the CI UI (CircleCI/other) |
| 3 | Triages against sentinel patterns in priority order (lint → test failure → formatter → type check → missing dependency → OOM → lockfile drift → permissions), stopping at the first match |
| 4 | Maps the failing CI step to a local command so you can reproduce it without waiting on another CI run |
| 5 | Returns a fixed-shape summary: check, one-sentence root cause, a `file \| line \| rule/test` table, whether local preflight would've caught it, and the fix |

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/investigate-ci-failure -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just ask, in your own words:

> "why did CI fail on this PR?"
> "<pasted CI run URL> — what broke?"
> "the build is red, what's going on"

The agent fetches the right log for the CI system in play, triages it, and hands back a short root-cause summary instead of the raw output.
