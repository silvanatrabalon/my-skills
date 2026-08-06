---
name: run-tests
description: Run tests in a monorepo or single-package project. Covers full suite, workspace-scoped, directory-scoped, and single-file runs across Node (Yarn/pnpm/npm workspaces), Python, Go, and Rust. Use when running, debugging, or iterating on tests, or when the user asks why a test is failing.
---

# Run Tests

**Audience:** Anyone running, debugging, or iterating on a test suite — in a monorepo or a single-package project.

**Goal:** Run tests at the right scope (full suite, workspace, directory, or single file) with the correct command for the project's stack, and read the failure output efficiently instead of re-running blind.

How to run tests at different scopes — full project, specific workspace/package, directory, or single file. Adapt the commands to your stack.

## Important: always run from the project root

In monorepos, **always run test commands from the root**, never by `cd`-ing into a workspace first.

```bash
# ✅ Correct (from root)
yarn workspace my-app test src/components/Button.test.tsx

# ❌ Wrong (from workspace dir)
cd apps/my-app && yarn test
```

---

## By stack

### Node / Yarn workspaces + Turborepo

```bash
# All tests in the repo
yarn turbo run test

# All tests for a specific workspace (use the package.json "name" field)
yarn turbo run test --filter=<workspace-name>

# All tests in a directory within a workspace
yarn workspace <workspace-name> test <relative-dir>

# Single test file within a workspace
yarn workspace <workspace-name> test <relative-path/to/file.test.ts>
```

### Node / pnpm workspaces

```bash
# All tests
pnpm --recursive run test

# Specific workspace
pnpm --filter <workspace-name> run test

# Single file (depends on test framework)
pnpm --filter <workspace-name> exec vitest run src/foo.test.ts
pnpm --filter <workspace-name> exec jest src/foo.test.ts
```

### Node / npm workspaces

```bash
npm run test --workspace=<workspace-name>
```

### Single-package Node project

```bash
# All tests
npm test        # or yarn test / pnpm test

# Specific file (Vitest)
npx vitest run src/foo.test.ts

# Specific file (Jest)
npx jest src/foo.test.ts

# Watch mode (Vitest)
npx vitest src/foo.test.ts

# Watch mode (Jest)
npx jest --watch src/foo.test.ts
```

### Python (pytest)

```bash
# All tests
pytest

# Specific directory
pytest tests/unit/

# Specific file
pytest tests/unit/test_auth.py

# Specific test
pytest tests/unit/test_auth.py::test_login_success

# With coverage
pytest --cov=src tests/
```

### Go

```bash
# All tests
go test ./...

# Specific package
go test ./internal/auth/...

# Specific test
go test ./internal/auth/ -run TestLogin

# With verbose output
go test -v ./...
```

### Rust

```bash
# All tests
cargo test

# Specific test
cargo test test_login

# Specific module
cargo test auth::
```

---

## Scoping strategy

| What you need | Command pattern |
|---|---|
| Full suite before pushing | `<root-command> --all` |
| Verify my change didn't break neighbors | `<root-command> --filter=<changed-workspace>` |
| Iterate on a feature | workspace/file-scoped command |
| Reproduce a specific failing test | single-test command |

## Common mistakes

| Mistake | Correct approach |
|---|---|
| `cd apps/my-app && yarn test` | Run from root: `yarn workspace my-app test` |
| Using full path including workspace dir | Use relative path within workspace: `src/foo.test.ts` not `apps/my-app/src/foo.test.ts` |
| `--testPathPattern` (Jest quirk) | Use direct file path |
| Running full suite to verify one file | Use workspace + file scope |

---

## Reading test output

- A passing test suite exits 0; failing exits non-zero.
- Look for `FAIL` / `ERROR` / `FAILED` lines to find the failing test file.
- Most frameworks print the assertion diff — read the `Expected` vs `Received` values.
- Stack traces point to the exact line. Go there first.

## After fixing a test

1. Re-run the same scoped command to confirm the fix.
2. Run the workspace-level suite to confirm no regressions.
3. Commit per the `conventional-commit` skill.
