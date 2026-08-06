---
name: investigate-ci-failure
description: Investigate a failing CI check (GitHub Actions, Jenkins, CircleCI, etc.) and return a short root-cause summary with file:line citations. Use when the user asks why CI failed, pastes a CI URL, or wants to understand a failing check without reading raw logs.
---

# Investigate CI Failure

**Audience:** Anyone facing a red CI check who wants the root cause, not a wall of raw log output.

**Goal:** Produce a **short root-cause summary** with `file:line` citations. Do not dump raw logs — compress to what matters.

## Step 1 — Identify the failing check

From a PR number:

```bash
gh pr checks <pr-number>
```

Look for checks marked `fail` or `×`. Note the check name and URL.

From a CI URL: paste the URL and parse the job name and build number.

## Step 2 — Fetch the log

### GitHub Actions

```bash
# List recent workflow runs
gh run list --limit 10

# View a specific run
gh run view <run-id>

# Get the full log
gh run view <run-id> --log-failed
```

Or open the Actions tab → failing job → expand the failing step.

### Jenkins

Append `/consoleText` to the job URL to get raw log output.
Requires VPN or appropriate network access.

### CircleCI / other

Open the failing step in the CI UI and copy the relevant output.

## Step 3 — Triage with sentinel patterns

Scan the log for the first match in this priority order:

| Pattern | Category |
|---|---|
| `error  ` / `ERROR` (lint format) | **Lint error** — blocks build |
| `FAIL` / `AssertionError` / `✗` | **Test failure** |
| `Code style issues found` / `would reformat` | **Formatter check failed** |
| `error TS` / `type error` | **Type check failure** |
| `Cannot find module` / `Module not found` | **Import/dependency error** |
| `ENOENT` / `No such file` | **Missing file** |
| `out of memory` / `heap` | **Memory/resource issue** |
| `lock file` / `package-lock.json` out of sync | **Dependency lockfile drift** |
| `permission denied` | **Auth / permissions issue** |

Stop at the **first** sentinel — fix root cause before investigating further.

## Step 4 — Reproduce locally

Map the failing CI step to a local command:

| CI step | Local equivalent |
|---|---|
| Lint | `npx eslint .` / `ruff check .` / `golangci-lint run` |
| Format check | `npx prettier --check .` / `black --check .` |
| Tests | `npm test` / `pytest` / `go test ./...` |
| Type check | `npx tsc --noEmit` / `mypy .` |
| Build | `npm run build` / `cargo build` |

Run the local equivalent scoped to the changed files first — it's faster.

## Output format

Return a summary in this structure:

```markdown
## CI failure summary

**Check:** <check name and run ID or URL>
**Root cause:** <one sentence>

| File | Line | Rule / test |
|---|---|---|
| `src/auth/session.ts` | 47 | `no-unused-vars` |
| `tests/auth.test.ts` | 112 | `AssertionError: expected 401, got 200` |

**Would preflight catch this?** <Yes — `<local command>` runs the same check> / <No — only in CI>

**Fix:** <one sentence>
```

## Tips

- **Start from the end of the log** — most CI systems print the summary at the
  bottom (e.g. `N errors found`, `FAILED tests`).
- **Lint errors vs warnings** — only errors typically block CI; scan for the
  summary line that says `N error(s), M warning(s)`.
- **Flaky tests** — if the test failure is intermittent with no code change,
  check for time-dependent assertions, missing mocks, or parallel test
  interference.
- **Dependency issues** — if `Cannot find module` or lockfile errors, run
  `npm install` / `yarn` / `pip install -r requirements.txt` locally and
  commit the updated lockfile.
- **Format failures** — run the formatter locally (`prettier --write .`),
  commit the result, and push.
