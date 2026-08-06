# conventional-commit

A skill that stages changes and writes git commits following [Conventional Commits](https://www.conventionalcommits.org/) — with the safety rails that keep a commit from becoming a mess. No language or stack dependency.

Pairs naturally with [`open-pull-request`](../open-pull-request): commit with this one, then open the PR with that one.

---

## What It Does

| Step | Action |
|------|--------|
| 1 | Inspects the working tree (`git status`, `git diff`) to decide what belongs in the commit |
| 2 | Stages deliberately — avoids blind `git add .`, never stages secrets |
| 3 | Picks the smallest accurate type (`feat`, `fix`, `chore`, `hotfix`, `wip`, ...) |
| 4 | Commits — single line, or a HEREDOC when the message needs a body |
| 5 | Verifies with `git status` + `git log -1` |

Also covers: when it's safe to `--amend` (never on a pushed commit without explicit approval), never force-pushing `main` without approval, and syncing a feature branch with `git fetch` + `merge`/`rebase`.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/conventional-commit -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just ask, in your own words:

> "commit this"
> "stage the changes and commit"
> "we're done with this feature, commit it"

The agent inspects the diff, stages deliberately, and writes a Conventional Commits message — never auto-committing secrets or force-pushing without asking first.
