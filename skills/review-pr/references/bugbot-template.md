# BUGBOT.md template

Copy this to the root of any repo as `BUGBOT.md` and fill in the project-specific
anti-patterns table at the bottom. It's optional project context for the
`review-pr` suite (link or paste it into `REVIEW.md` → Notes to specialists) and
doubles as a human-reviewer checklist. Covers **judgment calls automated tools
can't catch** — not formatting, imports, or basic lint rules.

---

```markdown
# BUGBOT.md — Code Review Guidelines

Guidelines for AI-assisted code review. Used by:
- The `review-pr` suite — paste or link this file as project context in `REVIEW.md`
- Human reviewers as a checklist

Automated tools (formatters, linters, type checkers) handle style, formatting,
and basic correctness. This file focuses on **issues requiring human/AI judgment**
that automated tools cannot catch.

---

## What automated tools already cover (DO NOT re-flag)

- Formatting (Prettier, Black, gofmt, rustfmt)
- Import order, unused imports
- Basic linting rules configured in your linter
- Test syntax enforcement (if you have lint rules for it)

---

## Security (Critical priority)

### Input validation and XSS

- All user inputs, URL params, query strings, and form data must be validated
  and sanitized before use.
- Flag `dangerouslySetInnerHTML`, `innerHTML`, or unescaped dynamic content in
  templates.
- Validate URLs before redirects to prevent open-redirect vulnerabilities.

### Data protection

- No API keys, tokens, credentials, or PII in client bundles, logs, error
  messages, or source control.
- Verify proper auth checks exist before accessing protected resources.
- Ensure proper handling when serializing/deserializing user data.

### Dependencies and configuration

- New dependencies should be vetted for known vulnerabilities.
- Cross-origin requests should be intentional and properly configured (CORS/CSP).

---

## Architecture and design (Critical priority)

### Separation of concerns

- Business logic separate from UI/presentation components.
- Data fetching separate from rendering.

### Single responsibility

- Functions and components should do one thing well.
- Flag functions over ~50 lines or components with many unrelated responsibilities.

### Code quality

- DRY violations: identify duplicated logic that should be extracted.
- No mixing high-level orchestration with low-level implementation in the same function.
- Public APIs should be intuitive, consistent, and self-documenting.
- Names should reveal intent — avoid abbreviations and generic names like `data`, `info`, `handler`.
- No magic values: constants should be named.

### Maintainability

- Flag tight coupling between modules that should be independent.
- Related functionality should be co-located, not scattered.
- Code should be extensible without modification (Open/Closed).
- Design should support easy unit testing.

---

## Performance (High priority)

### Rendering (UI frameworks)

- Functions created in render paths causing unnecessary re-renders.
- Missing memoization for expensive computations.
- Large objects/arrays passed through props causing child re-renders.
- Inline object/array creation in render hot paths.

### Data and network

- N+1 patterns in data fetching or rendering loops.
- Unnecessary network requests or missing caching/deduplication.
- Synchronous operations that should be async (blocking the main thread).

### Resource management

- Memory leaks: event listeners not cleaned up, subscriptions not cancelled,
  intervals/timers not cleared.
- Bundle size impact of new dependencies — prefer lighter alternatives.

---

## Error handling (High priority)

- Errors swallowed silently without logging or user feedback.
- Inconsistent error handling patterns across the codebase.
- Missing error boundaries for component trees (React / similar).
- Unhandled promise rejections.
- Generic error messages that don't help debugging or user recovery.

---

## Async patterns (Medium priority)

- Race conditions in concurrent operations.
- Missing cancellation for in-flight requests (`AbortController`, cancel tokens).
- Stale data from outdated async responses.
- `useEffect` with async operations missing cleanup.
- Optimistic updates without proper rollback on failure.

---

## PR quality

### Test coverage

- New source code without tests → flag as a gap.
- Modified logic without updated tests → stale tests are a false safety net.
- Bug fixes without regression tests → should have a test that would have failed
  before the fix.
- Deleted or skipped tests without removing the corresponding source → flag.

### Documentation freshness

- Public API changes without updated docs → flag.
- New shared components/utilities without usage docs → flag.
- ADRs that are being reversed or superseded without updating `docs/decisions/`.

### Communication

- Breaking changes documented and communicated.

---

## Common anti-patterns to flag

<!-- Fill in project-specific patterns your team has seen repeatedly. Examples: -->

| Pattern | Issue |
|---|---|
| Functions in `mapStateToProps` / render closures | Creates new function refs each render |
| Subscribing to the entire state object | Passes too much; breaks memoization |
| `eslint-disable` at file level | Hides real issues |
| Catching and silently discarding errors | Silent failures hide bugs |
| Race conditions in concurrent requests | Wrong response wins depending on timing |

---

## References

- Architecture Decision Records: `docs/decisions/`
- PR standards: see `AGENTS.md` → Pull requests
- Specialist agents: this skill's `references/agents/` (code-reviewer, security-auditor, etc.)
```
