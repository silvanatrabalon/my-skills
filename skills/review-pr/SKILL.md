---
name: review-pr
description: Multi-phase PR review orchestrator. Runs scoped specialist subagents, a challenger pass, and writes a local priorities.md. Works with any GitHub repo and any tech stack. Local only — never posts to GitHub. Use when the user asks to review a PR, wants a multi-specialist local review before merging, or invokes review-pr <n>. Not for publishing findings — that's review-pr-curate then review-pr-post.
---

# review-pr — PR review orchestrator

**Audience:** Anyone who wants a thorough, multi-angle local review of a GitHub PR before merging — without waiting on a human reviewer's first pass, and without posting anything automatically.

**Goal:** Orchestrate a **local-only**, multi-specialist PR review for any GitHub repository and any tech stack.

Output: a **per-pass folder** under `docs/reviews/` with:
- `priorities.md` — human deliverable (start here)
- `challenger.md` — challenger ledger + budget overflow
- `specialists/<name>.md` — raw output per specialist that ran

> Local only — no GitHub comments are posted automatically.
> Use `review-pr-curate` then `review-pr-post` to publish selectively.

## Prerequisites

- `gh` authenticated (`gh auth status`)
- Working directory inside the target repo (or supply a full `{owner}/{repo}#<n>` reference)
- The Agent tool available for subagent fan-out

## Specialist agents

Unlike a setup that relies on pre-registered custom agent types, this skill is
self-contained: the full role definition for each specialist lives in
`references/agents/<name>.md`. When spawning a specialist, read its file and pass
the **entire body** as the `ROLE:` section of that subagent's prompt (see
[Specialist invocation contract](#specialist-invocation-contract)) — spawn with a
general-purpose subagent, not a named custom type. This means the skill works
immediately after install, with no separate agent-registration step.

| Agent | Role |
|---|---|
| `code-reviewer` | Implementation quality, AI-slop lens, SOLID, complexity |
| `security-auditor` | Trust boundaries, secrets, auth bypass, fail-closed |
| `test-reviewer` | Test quality, mock-only assertions, regression contracts |
| `performance-reviewer` | Waterfalls, barrel imports, re-renders, N+1 queries |
| `a11y-auditor` | WCAG 2.1 AA, ARIA, focus management |
| `challenger` | Adversarial filter: KEEP/WEAKEN/DROP per finding |

## Step 1 — Identify the PR

Accept: PR number, GitHub PR URL, or branch name.

```bash
REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner')

gh pr view <n> --json number,title,author,isDraft,headRefName,baseRefName,headRefOid,body,files
gh pr diff <n>
gh api repos/$REPO/pulls/<n>/files --paginate
```

## Step 2 — Load REVIEW.md

Read `REVIEW.md` at repo root. It contains project-specific tuning: suppressed
categories, touch-density gates, pre-flight rules. If the repo doesn't have one
yet, copy `references/review-md-template.md` from this skill to the repo root
as `REVIEW.md` and ask the user to customize it — or proceed with defaults and
note it in `priorities.md` metadata if they'd rather not set it up yet.

## Step 2.5 — Resolve review profile

Implement `resolveProfile(prMetadata, changedFiles, slashArgs)`:

| Profile | Auto-detect signals (first match wins) | Specialists allowed |
|---|---|---|
| `spike` | Title starts with `wip:` or `spike:` | `code-reviewer` only |
| `release` | Merge to `main`, version bumps in `package.json` / lockfile, `hotfix:` prefix | full roster |
| `feature` | default | code gate + risk-gated outliers |

**Override:** slash arg `profile:release` or `profile:spike` wins over auto-detect.

Record in metadata: `profile`, `profile_reason` (one-line detection rationale).

## Step 2.6 — Trust-erosion alarms (optional)

At orchestrator start, print one-line warnings (do not auto-suppress roster):

### Human precision (post-close)

If `docs/reviews/.signal-ratios.json` exists, compute per-specialist precision
over the last 5 PRs for the resolved profile. If any specialist is below **40%**
precision (`(acted + acted-with-drift) / (acted + acted-with-drift + dismissed + deferred)`):

```
security-auditor is below human precision threshold for feature profile (28% over last 5 PRs);
consider suppressing in REVIEW.md — not auto-suppressed.
```

### Pre-challenger retain rate

If `docs/reviews/.specialist-retention.json` exists, compute per-specialist
`retain_rate` over the last 5 passes for the resolved profile
(`findings_retained_post_challenger` / `findings_emitted`). If any specialist is below **25%**:

```
performance-reviewer retain rate is below threshold for feature profile (0% over last 5 passes);
consider touch-density gates in REVIEW.md — not auto-suppressed.
```

## Step 3 — Resolve human reviewer slug

First name only, lowercase `[a-z0-9-]`:

1. User override — `reviewer:alice` or "review as alice"
2. Default — `gh api user --jq '.name // empty'`, first token, lowercased
3. Fallback — ask user

## Step 4 — Detect review pass (folder layout)

Glob `docs/reviews/pr-<n>-review-<reviewer-slug>-pass-*/`.

- `pass = max(existing) + 1`, or `1` if none
- Output dir: `docs/reviews/pr-<n>-review-<reviewer-slug>-pass-<pass>/`

Create `specialists/` subdirectory when writing output.

## Step 5 — Prior pass context (pass ≥ 2)

Read `pass-<pass-1>/priorities.md`. Parse **Must Fix** and **Should Fix** into
**PRIOR PASS CONTEXT**:

```
finding-id | severity | file:line | rationale-summary
```

## Step 6 — Risk-surface scan + specialist roster

Run a **deterministic** pre-flight scope scan on diff hunks (shell + ripgrep, no LLM).
Classify surfaces:

| Surface | Detection heuristics (diff hunks) | Unlocks specialist |
|---|---|---|
| `interactive-ui` | `onClick`, `onKeyDown`, `role=`, `<form`, `<input`, `<button`, modal/dropdown patterns | `a11y-auditor` |
| `auth-security` | `auth`, `session`, `password`, `token`, `jwt`, `secret`, `dangerouslySetInnerHTML`, env/credential patterns | `security-auditor` |
| `data-fetching` | `fetch(`, `async`+data patterns, database queries, API route handlers, `Promise.all` | `performance-reviewer` |

A specialist runs only when **both** the resolved profile allows it **and** the
risk surface matches (or profile is `release`, which enables all surfaces).

### Touch-density gates (outliers)

After surface detection, apply minimum **lines added** thresholds from
`REVIEW.md` **## Specialist touch-density gates**. Use `git diff --numstat`
between merge-base and PR head (or `gh pr diff <n> --numstat`).

1. Sum `additions` column for files matching the specialist's path patterns.
2. If sum < threshold, skip specialist with reason `below-touch-threshold`.
3. `release` profile bypasses touch-density gates.

### Profile → base roster

| Specialist | spike | feature | release |
|---|---|---|---|
| code-reviewer | ✓ | ✓ | ✓ |
| test-reviewer | — | ✓ | ✓ |
| security-auditor | — | if `auth-security` | ✓ |
| performance-reviewer | — | if `data-fetching` | ✓ |
| a11y-auditor | — | if `interactive-ui` | ✓ |

Record `specialists_active`, `risk_surfaces_detected`, and `specialists_skipped`
(with reason) in metadata.

## Step 6.5 — Deterministic pre-flight rules

Before phase 1, run shell + ripgrep rules from `REVIEW.md` **## Pre-flight rules**
against the PR diff.

Emit findings with `specialists: pre-flight`, `confidence: High`. Flow into the
same triage pipeline as specialist findings.

Tell every specialist in the prompt envelope:

> Pre-flight already covers the patterns in REVIEW.md ## Pre-flight rules.
> Stay silent on those patterns (silence is valid).

Hardcoded rules (always run even if not in REVIEW.md):

- Lockfile-only diff with no manifest change → Warning, `category: convention`
- `.github/workflows/**` permission escalation (`permissions: write-all` or new
  `contents: write` without justification) → Critical, `category: security`

## Step 7 — Two sequential phases

Run phases **sequentially**. Within each phase, spawn specialists concurrently.

### Phase 1 — Code gate

Spawn: `code-reviewer` + `test-reviewer` (when rostered).
Collect findings → build **CODE CONTEXT** for phase 2.

### Phase 2 — Outliers

Spawn rostered outlier specialists (`security-auditor`, `performance-reviewer`,
`a11y-auditor`) with REVIEW.md + CODE CONTEXT + PRIOR PASS (if pass ≥ 2).

### Per-specialist file write

Immediately after each specialist returns, write **untouched** markdown body to:

```
docs/reviews/pr-<n>-review-<reviewer>-pass-<pass>/specialists/<agent-name>.md
```

Specialists that did not run produce **no file**.

## Step 8 — Triage (deterministic, no extra LLM)

Parse the **JSON channel** from each specialist response (see
[JSON schema](#structured-json-channel)). Fall back to markdown parsing only when
JSON is missing or invalid (warn in metadata).

Apply in order:

### 8.1 Normalize severity

| Source | Source value | Normalized |
|---|---|---|
| a11y-auditor | Critical / WCAG-A blocker | Critical |
| a11y-auditor | Major | Warning |
| a11y-auditor | Minor | Info |
| All others | Critical / Warning / Info | (unchanged) |

### 8.2 Drop invalid findings

Remove Critical/Warning without `file:line` from diff or session read.

### 8.3 Dedupe (geometric)

Key: `(file, line ± 2, category)`. Merge specialists; promote one severity tier;
keep best rationale; preserve all fixes.

### 8.4 Merge reconciliation rows (pass ≥ 2)

Dedupe prior-pass verification rows; `regressed` on Must Fix → Critical.

### 8.5 Route to sections

- Critical → Must Fix
- Warning → Should Fix
- Info + style/nit → Nits

### 8.6 Sort Must Fix and Should Fix

Category order: `security`, `bug`, `test-gap`, `complexity`, then rest;
tie-break file path. Nits: file path only.

### 8.7 Assign finding IDs

`MF-*`, `SF-*`, `N-*` — stable for next pass reconciliation.

### 8.8 Output budget rules (apply in Step 9.5)

Caps apply to findings destined for **`priorities.md` only** — specialist files
stay unfiltered.

**Base caps:**

| Profile | Should Fix cap | Nits cap |
|---|---|---|
| `spike` | 3 | 5 |
| `feature` | 10 | 15 |
| `release` | 20 | 30 |

**PR size multiplier** — count changed files:

| Changed files | Multiplier |
|---|---|
| ≤ 5 | × 0.5 |
| 6–25 | × 1.0 |
| 26–100 | × 1.5 |
| > 100 | × 2.0 |

`effective_cap = max(1, floor(base_cap × multiplier))`.

## Step 9 — Challenger (sequential)

### Same-family pass (default)

Spawn `challenger` with triaged finding list (structured summaries only), PR
diff, changed files, REVIEW.md.

Apply lossy rules:

- Category cluster: 3+ same category + same feature scope → WEAKEN all but most concrete
- Confidence floor: single specialist + Medium/Low → default WEAKEN unless evidence unambiguous
- Minimum drop budget: target ≥30% DROP or WEAKEN unless 2+ specialists corroborate at High
- CI-overlap: restates pre-flight or REVIEW.md suppressed categories → DROP

### Cross-family pass (optional)

When your Agent tool supports a model override, run a **second** challenger on a
different model. Override via slash arg `challenger-model:<slug>`.

Second pass receives same triaged list + first-pass verdicts. May only DROP or WEAKEN
further (no net-new findings on cross-family pass).

Write full challenger ledger to `challenger.md`.

### Step 9.5 — Apply output budget (after challenger)

Truncate post-challenger **Should Fix** and **Nits** using effective caps.
**Must Fix is never budget-capped.**

When over budget, keep findings ranked by `(severity, confidence, num_specialists)`
descending. Overflow moves to a collapsed `<details>` block in `challenger.md`
under **Budget overflow** — never deleted.

Add summary line in `priorities.md` nits section when truncated:
`+N more nits — see challenger.md budget overflow`.

## Step 10 — Render and write folder

1. Render `priorities.md` using `references/priorities-template.md`.
2. Write `challenger.md` with verdict ledger + budget overflow.
3. Ensure each `specialists/<name>.md` was written in Step 7.
4. Write `retention.json` in the pass folder.

### Step 10.5 — Specialist retention metrics

After challenger filtering and budget application, compute per specialist:

| Field | Meaning |
|---|---|
| `findings_emitted` | Count in JSON `findings[]` (pre-triage) |
| `findings_retained_post_challenger` | Count still in Must Fix / Should Fix / Nits after challenger |
| `retain_rate` | `retained / emitted` (1.0 when emitted = 0) |

Write pass-local `retention.json`:

```jsonc
{
  "pr": 42,
  "profile": "feature",
  "pass": 1,
  "head_sha": "abc1234",
  "reviewed_at": "2026-01-15",
  "specialists": [
    {
      "name": "performance-reviewer",
      "findings_emitted": 2,
      "findings_retained_post_challenger": 1,
      "retain_rate": 0.5
    }
  ]
}
```

Append the same record to `docs/reviews/.specialist-retention.json`
(gitignored, append-only array).

## Step 11 — Print summary

Tell the user:

- Output folder path and **start at `priorities.md`**
- Pass number, profile, specialists active/skipped
- Must-fix / should-fix / nits counts (post-challenger, post-budget)
- Effective budget caps
- Signal ratio: `(MF+SF) / (MF+SF+Nits)` in priorities
- Specialist retention highlights
- Reconciliation progress (pass ≥ 2)
- Final verdict
- Reminder: local only; use `review-pr-curate` then `review-pr-post` to publish

---

## Structured JSON channel

Specialists emit a fenced JSON block before `Verdict:`:

```json
{
  "schema": "review/finding/v1",
  "findings": [
    {
      "id": "code-reviewer-001",
      "title": "Import-time side-effect in module scope",
      "severity": "Warning",
      "confidence": "High",
      "category": "bug",
      "file": "src/lib/client.ts",
      "line": 12,
      "rationale": "...",
      "severity_rationale": "Warning not Critical because display-only, not data loss",
      "fix": "...",
      "evidence_quote": "fetch('/api/...')"
    }
  ],
  "reconciliation": [],
  "verdict": "comments"
}
```

Orchestrator triage uses JSON `findings[]` as primary; markdown is for human
appendix files only.

---

## Specialist invocation contract

Read the specialist's full role definition from `references/agents/<name>.md` and
prepend its entire body to the prompt:

```
ROLE: <full body of references/agents/<name>.md>

PROJECT CONTEXT (from REVIEW.md):
<contents>

PROFILE: <profile> (<profile_reason>)

RISK SURFACES: <list or "none">

PREFLIGHT: Patterns in REVIEW.md ## Pre-flight rules are already checked — stay silent on those.

CODE CONTEXT (phase 2 only):
<phase-1 summary or "none">

PRIOR PASS CONTEXT (pass ≥ 2 only):
<structured list or "none — pass 1">

SCOPE:
- PR: {owner}/{repo}#<number> — <title>
- Head SHA: <headRefOid>
- Tracker ref: <key or N/A>
- Human reviewer: <reviewer-slug> (metadata only)
- Review pass: <pass>
- Changed files: <list>
- Local repo: <absolute path>

MODE: report-only
- Do NOT post to GitHub.
- Do NOT write files (orchestrator writes specialists/<name>.md).
- Return markdown body + JSON block per schema.

OUTPUT FORMAT — every finding MUST include in JSON:
- severity: Critical | Warning | Info
- confidence: High | Medium | Low
- category: bug | security | performance | a11y | complexity | test-gap | convention | style | nit
- severity_rationale: one sentence — why this severity, not one tier up or down (required for Critical and Warning)

Verification bar: Critical/Warning require file:line from diff or repo read.
Silence is valid when nothing meets High/Medium confidence.

Reconciliation (pass ≥ 2): emit rows in JSON reconciliation[] for PRIOR PASS items in scope.

ACCEPTANCE: file:line, rationale, suggested fix. End markdown with JSON block, then:
Verdict: approve | comments | request-changes
```

### Challenger contract

```
ROLE: <full body of references/agents/challenger.md>
PROJECT CONTEXT: <REVIEW.md>
PROFILE: <profile>
INPUT: triaged finding list only (structured JSON summaries)
SCOPE: PR diff + changed files
TASK: KEEP | WEAKEN | DROP per finding; ≤3 net-new High-confidence misses (same-family only)
DROP BUDGET: ≥30% DROP+WEAKEN unless 2+ specialists corroborate at High
OUTPUT: verdict table + optional net-new; orchestrator writes challenger.md
```

Cross-family challenger: same input + prior verdicts; DROP/WEAKEN only; no net-new.

---

## Guardrails

- **No `gh` write calls** from orchestrator — no reviews, comments, or PR mutations
- **Only the orchestrator writes** `priorities.md`, `challenger.md`, `retention.json`, `specialists/*`
- **Phases are sequential** — never start outliers before code gate completes
- **Never auto-post** — curate/post is a separate step

## Reference files

- `references/agents/*.md` — full role definitions for the six specialists, injected as `ROLE:` when spawning each subagent.
- `references/priorities-template.md` — the `priorities.md` rendering template.
- `references/review-md-template.md` — `REVIEW.md` template to copy into a repo that doesn't have one yet.
- `references/bugbot-template.md` — `BUGBOT.md` template: a human-judgment review checklist, optional context for specialists.
