# REVIEW.md template

Copy this to the root of any repo as `REVIEW.md` and edit the sections below. It's
read by the `review-pr` orchestrator at the start of every review to customize
specialist behavior, add pre-flight rules, and suppress noise for that specific
project. If a repo doesn't have this file yet, `review-pr` proceeds with defaults
and notes it in `priorities.md` metadata — don't invent project specifics on its
behalf.

---

```markdown
# REVIEW.md — PR review tuning

This file is read by the `review-pr` orchestrator at the start of every review.
It lets you customize specialist behavior, add pre-flight rules, and suppress noise
for your specific project.

---

## Project context

<!-- One paragraph describing the project. Specialists read this for stack-aware reasoning.
Example: -->

This is a [TypeScript / Python / Go / ...] application using [your stack].
Key areas of sensitivity: [auth, payments, data pipeline, etc.].

---

## Suppressed categories

<!-- List finding categories that are always noise for this project.
Specialists will not emit findings in these categories.

Allowed values: bug | security | performance | a11y | complexity | test-gap | convention | style | nit

Example:
- style        # handled by Prettier/Black/gofmt in CI
- convention   # covered by our custom ESLint rules
-->

- style

---

## Pre-flight rules

<!-- Deterministic shell/ripgrep rules that run before specialists.
These fire on every PR regardless of profile.
Format: description | command | severity | category

Examples:
-->

- Hardcoded `localhost` in non-test files | `rg -l 'localhost' --glob '!**/*.test.*' --glob '!**/*.spec.*'` | Warning | convention
- `console.log` left in production code | `rg -l 'console\.log' src/` | Info | style
- TODO/FIXME comments in changed files | `rg -l 'TODO|FIXME'` | Info | convention

---

## Specialist touch-density gates

<!-- Skip outlier specialists when their surface has fewer than N lines added.
This prevents noise from specialists reviewing trivial changes.

Format: specialist | min_lines_added | path_glob

Example:
-->

| Specialist | Min lines added | Path glob |
|---|---|---|
| performance-reviewer | 30 | `src/**` |
| a11y-auditor | 20 | `src/**/*.{tsx,html,jsx,vue,svelte}` |
| security-auditor | 10 | `src/**` |

---

## Output budget overrides

<!-- Override the default Should Fix / Nits caps per profile.
Leave blank to use orchestrator defaults.

Example:
-->

<!-- | Profile | Should Fix cap | Nits cap |
|---|---|---|
| feature | 8 | 10 |
| release | 15 | 20 | -->

---

## Notes to specialists

<!-- Free-form guidance sent to all specialists.
Use for project-specific conventions, known false-positive patterns, or
areas to pay extra attention to.

Examples:
- "All API routes require request validation via zod schemas."
- "The `legacy/` folder is read-only — do not suggest refactors there."
- "Prefer functional components; class components in `src/ui/` are intentional."
-->
```
