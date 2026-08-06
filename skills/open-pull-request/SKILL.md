---
name: open-pull-request
description: Push the current branch and open a GitHub pull request with a well-structured body, using the gh CLI. Use when the agent is about to open a PR, when the user asks to "open a PR" / "push and open a PR" / "make a PR", or after a feature branch's commits are ready for review. Not for creating the commits themselves — use the conventional-commit skill first.
---

# Open Pull Request

**Audience:** Anyone working in a Git branch whose commits are ready for review.

**Goal:** Push the branch and open a GitHub PR with a title and body that give a reviewer everything they need on the first read — no back-and-forth to ask what changed or how to verify it.

Procedural recipe for pushing a feature branch and opening a GitHub PR using the `gh` CLI. Works with any language or stack — no framework dependencies.

## Prerequisites

- `gh` authenticated (`gh auth status`)
- Working tree clean or only intentional changes staged
- On the feature branch you want to PR

## Title

Same shape as [Conventional Commits](https://www.conventionalcommits.org/) (see the `conventional-commit` skill):

```
<type>(<scope>): <subject>
```

Optionally append a tracker reference: `[TICKET-###]`, `closes #42`, etc.

Good examples:

```
feat(auth): add OAuth2 login flow
fix(api): handle null user response
chore(deps): bump vitest to 2.1.0
docs: update contributing guide
```

For squash-merged PRs this title becomes the commit on `main` — use a clear conventional title so history stays readable.

## Body structure

A good PR body answers three questions for the reviewer:

```markdown
## What It Does

<What changed and why. Bullet points are fine.>

## How To Test

<Actionable steps the reviewer can follow to verify the change.>
<For non-runtime changes (docs, config, CI), name the verification surface
(e.g. "CI lint on this PR" or "run `yarn test` locally").>
<An empty section is worse than a brief explanation — never leave it blank.>

## Notes

<Optional: caveats, follow-up tickets, stacked-PR context, out-of-scope items.>
```

## Workflow

### Step 1 — Confirm the working tree

```bash
git status
git log --oneline origin/main..HEAD   # commits that will be in the PR
```

### Step 2 — Push the branch

```bash
git push -u origin HEAD
```

`-u` sets the upstream so subsequent `git push` calls don't need an explicit remote/branch.

### Step 3 — Detect the current repo

```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
# e.g. "acme/my-app"
```

Use this value anywhere you need `{owner}/{repo}` below.

### Step 4 — Compose the body

Build the body in a HEREDOC **before** calling `gh pr create`:

```bash
PR_BODY="$(cat <<'EOF'
## What It Does

- <bullet 1>
- <bullet 2>

## How To Test

1. <step 1>
2. <step 2>

## Notes

<optional>
EOF
)"
```

### Step 5 — Open the PR

```bash
gh pr create \
  --base main \
  --title "feat(scope): short description" \
  --body "$PR_BODY"
```

Add labels if applicable:

```bash
gh pr edit --add-label bug --add-label documentation
```

### Step 6 — Verify CI

```bash
gh pr view        # confirm title, body, base branch
gh pr checks      # watch CI kick off
```

If a check fails, read the workflow output — each check prints exactly what it expected vs. what it got. Fix via `gh pr edit --title "..."` or `gh pr edit --body "$NEW_BODY"`, then push a follow-up commit if needed.

## Draft vs. ready

Opening as a draft (`--draft`) defers CI checks in most repo setups. The checks re-run the moment you mark the PR ready. Don't rely on a green draft as proof of conformance.

## Never

- Open a PR without filling `## What It Does` and `## How To Test` — an empty section is a red flag for reviewers.
- Set the base branch to anything other than `main` unless stacking on top of another open PR. If stacking, say so in the body and call out the rebase order.

## Quick reference

```bash
git push -u origin HEAD

gh pr create \
  --base main \
  --title "<type>(<scope>): <subject>" \
  --body "$(cat <<'EOF'
## What It Does

<what>

## How To Test

<how>

## Notes

<optional>
EOF
)"

gh pr checks
```
