# open-pull-request

A skill that pushes the current branch and opens a GitHub pull request with a consistent, reviewer-friendly body — using the `gh` CLI. No framework or language dependencies; works with any GitHub-hosted repo.

Pairs naturally with the [`conventional-commit`](../conventional-commit) skill: commit with that one, then open the PR with this one.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Confirms the working tree and lists the commits that will land in the PR |
| 2 | Pushes the branch (`git push -u origin HEAD`) |
| 3 | Detects the current repo via `gh repo view` |
| 4 | Composes the PR body in a fixed structure: **What It Does**, **How To Test**, **Notes** |
| 5 | Opens the PR with `gh pr create`, title in Conventional Commits shape |
| 6 | Confirms CI kicked off with `gh pr checks` |

Never opens a PR with an empty "What It Does" or "How To Test" section, and never changes the base branch away from `main` unless the PR is explicitly stacked on another one.

---

## Prerequisites

- [`gh` CLI](https://cli.github.com/) authenticated (`gh auth status`)
- A GitHub-hosted repository
- A feature branch with commits ready for review

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/open-pull-request -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just ask, in your own words — the skill triggers on intent, not on an exact phrase:

> "push this and open a PR"
> "make a PR for this branch"
> "I'm done with the feature, open the pull request"

The agent pushes the branch, drafts the body, and opens the PR via `gh`.
