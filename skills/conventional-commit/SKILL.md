---
name: conventional-commit
description: Stage code changes and create git commits using Conventional Commits format. Use when the agent has made changes that need to be committed, when the user asks to commit/stage, or when a logical unit of work is done. Not for opening a pull request — use the open-pull-request skill after committing.
---

# Conventional Commit

**Audience:** Anyone committing changes in a Git repository, in any language or stack.

**Goal:** Produce commits with a consistent, readable `git log` — using [Conventional Commits](https://www.conventionalcommits.org/) — without skipping the safety checks that keep a commit from becoming a mess (secrets, blind `git add .`, unsafe amends).

## Format

```
<type>(<scope>): <subject>
```

Optionally append a tracker reference: `[TICKET-###]`, `(#42)`, `closes #42`, etc.

- `<type>` ∈ `build | chore | ci | docs | feat | fix | hotfix | debug | perf | refactor | revert | style | test | wip`
- `<scope>` — optional, lowercase; the area or package being changed (e.g. `auth`, `api`, `ui`)
- `<subject>` — short imperative summary; keep the header ≤ 120 chars

## Workflow

### Step 1 — Inspect the working tree

```bash
git status
git diff
git diff --staged   # if anything is already staged
```

Understand what's modified, untracked, and already staged.
Decide if the logical change is one commit or should be split.

### Step 2 — Stage the change

```bash
git add path/to/file1 path/to/file2
git add path/to/dir/
```

Avoid `git add .` unless you've reviewed `git status` and the diff covers everything
you intend to commit. **Never stage secrets** (`.env`, credentials, private keys, tokens).

### Step 3 — Craft the message

Choose the smallest accurate `<type>`:

| Type | Use for |
|---|---|
| `feat` | User-visible new behavior |
| `fix` | Bug fix |
| `perf` | Performance improvement; no behavior change |
| `refactor` | Internal restructuring; no behavior change |
| `docs` | Documentation-only changes |
| `test` | Test-only changes |
| `chore` | Tooling, config, dependencies, scaffolding |
| `build` | Build-system or external-dependency changes |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting only (Prettier/ESLint --fix) |
| `revert` | Reverts a previous commit |
| `hotfix` | Out-of-process production fix |
| `debug` | Throwaway debugging commit |
| `wip` | Work-in-progress on a branch you control |

Scope is optional but useful — name the area the change touches.

### Step 4 — Commit

**Single line:**

```bash
git commit -m "feat(auth): add OAuth2 login flow"
```

**Multi-line — always use a HEREDOC** so newlines and quoting are preserved:

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add OAuth2 login flow

Implements authorization-code with PKCE. Token stored in httpOnly
cookie; refresh handled transparently by the middleware.
EOF
)"
```

### Step 5 — Verify

```bash
git status
git log -1
```

Confirm the working tree is clean and the message is what you intended.

## Amend rules

Only amend the HEAD commit when **all** of these are true:

1. The previous `git commit` **succeeded** (visible in `git log`).
2. A hook auto-modified files (e.g. Prettier on staged paths) and you need to fold
   them in, **or** the user explicitly asked.
3. The commit has **not been pushed** (`git status` shows "Your branch is ahead").

If the commit has been pushed, never amend without explicit user approval — it
requires a force-push.

## Never

- `--amend` on a pushed commit without explicit user approval
- `push --force` to `main` / `master` without explicit user approval
- Commit secrets (`.env`, credentials, tokens, private keys)
- Edit `git config` without permission

## Syncing the base branch into a feature branch

```bash
git fetch origin main
git merge origin/main
# or, for linear history:
git rebase origin/main
```

## Worked example

```bash
git status
# modified: src/auth/oauth.ts
# untracked: src/auth/oauth.test.ts

git diff src/auth/oauth.ts

git add src/auth/

git commit -m "$(cat <<'EOF'
feat(auth): add OAuth2 authorization-code flow with PKCE

Implements the full authorize → callback → token exchange sequence.
Refresh token rotation is handled in the middleware layer.
EOF
)"

git status
git log -1
```
