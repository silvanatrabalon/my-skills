# run-tests

A skill that runs tests at the right scope — full suite, workspace, directory, or single file — with the correct command for the project's stack. No framework dependencies of its own; it's a reference table plus a scoping strategy, not a script.

---

## What It Does

| Section | What it gives the agent |
|---|---|
| Root-first rule | Always run from the project root in monorepos — never `cd` into a workspace first |
| Commands by stack | Yarn/Turborepo, pnpm workspaces, npm workspaces, single-package Node, pytest, Go, Rust — each with full / workspace / directory / single-file variants |
| Scoping strategy | Which command pattern fits "verify my change didn't break neighbors" vs. "reproduce one failing test" |
| Reading output | Where to look first: `FAIL`/`ERROR` lines, `Expected` vs `Received`, stack traces |
| Common mistakes | e.g. using Jest's `--testPathPattern` instead of a direct file path |

After a fix, it points to the [`conventional-commit`](../conventional-commit) skill to close the loop.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/run-tests -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just ask, in your own words:

> "run the tests for this file"
> "run the full suite before I push"
> "why is this test failing"

The agent picks the right scope and command for your stack instead of guessing or running the whole suite when a single file would do.
