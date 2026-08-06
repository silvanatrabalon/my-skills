---
name: trinity-workflow
description: 'Bootstrap the "Trinity Workflow" in a repository for the first time — a spec-driven development process that combines OpenSpec (proposal/spec/design/tasks before code) with a prior backlog-refinement step using project-tuned agents (architect, backend-developer, frontend-developer). Use this when the user asks to install, set up, bootstrap, or configure "Trinity Workflow" in a repo, wants to combine OpenSpec with agent-based backlog refinement, or wants every feature to go through a reviewed proposal before implementation starts. This is a one-time setup skill: it installs OpenSpec, writes openspec/config.yaml with the real project context, creates or restructures BACKLOG.md, creates the three refinement agents, ensures a conventional-commit skill exists, and documents everything in CONTRIBUTING.md and CLAUDE.md. Not for implementing a feature, running /opsx:propose or /opsx:apply day-to-day, or refining one backlog item — those happen after setup, using what this skill creates.'
---

# Trinity Workflow Setup

**Audience:** Someone setting up how their team will build features from now on, in a repo that doesn't have this process yet.

**Goal:** Leave the repo with OpenSpec installed, `openspec/config.yaml` describing the real stack, a backlog shaped the way this team actually works, three refinement agents grounded in this project's conventions, a conventional-commit skill, and `CONTRIBUTING.md` + `CLAUDE.md` documenting the flow — so the very next backlog item can go through Trinity end to end.

**Do not implement any feature as part of this skill.** This is setup only.

## Why this exists

A raw backlog bullet ("Sistema de rutas protegidas: guards, roles, redirecciones") is too ambiguous to hand straight to `/opsx:propose`. Doing so anyway produces a proposal with real gaps — nested roles? the unauthorized-access message? — that only surface once code has already been written against them.

Trinity inserts one step before OpenSpec is touched: the backlog item gets refined first, in chat, by an agent tuned to this project (architect, backend, or frontend, whichever fits). That agent surfaces ambiguities, proposes a concrete solution, flags whether tests are needed, and writes a refined version of the requirement back into the backlog. Only then does OpenSpec enter the picture.

Metaphor worth keeping for `CONTRIBUTING.md` and for explaining this to teammates: the model is Neo — capable of implementing almost anything, but blind if it starts from an ambiguous bullet. Trinity's agents + human refinement step is what gives it real context first. OpenSpec is the Matrix: a world with explicit rules where, once briefed, the model can move precisely.

## The day-to-day Trinity flow (what gets documented, not run now)

1. Read the item from the backlog.
2. Refine it in chat with the right agent — no code, no `openspec/` yet; refinements land back in the backlog.
3. Run `/opsx:propose` using the refined requirement, never the original raw bullet.
4. Review the generated proposal (proposal, design, tasks) before applying anything.
5. Run `/opsx:apply`, and require it to finish with all tests passing.
6. Review the implementation manually and/or by running the tests.
7. Commit: confirm the spec's tasks are done, use the conventional-commit skill, update the backlog with status + commit hash.
8. Run `/opsx:archive` once the feature is finished and stable.
9. Commit the archive as the final step.

Everything below is the **setup** that makes steps 1-9 possible. Don't run steps 1-9 yourself as part of this setup — that starts with the team's first real backlog item, after setup is done (see the final summary).

## Setup Step 0 — Check prerequisites

Run `node --version`. OpenSpec needs Node.js ≥ 20.19.0. If Node is missing or too old, tell the user and **stop here** — don't install or change Node versions yourself.

## Setup Step 1 — Install and initialize OpenSpec

- Check for an existing `openspec/` folder at repo root. If it exists, **don't touch it**: show what's there (current `config.yaml`, existing specs) and ask the user how they want to migrate or merge before continuing.
- If it doesn't exist, install the CLI globally:
  ```bash
  npm install -g @fission-ai/openspec@latest
  ```
  Use the repo's actual package manager (pnpm/yarn/bun) if `npm` isn't what this project uses.
- If global install fails on a permissions error, tell the user and stop — don't retry with `sudo` or another workaround on their behalf.
- Run `openspec init` at repo root. It's interactive — when it asks which AI assistant, choose **Claude Code**. This generates `openspec/` plus `.claude/skills/` and `.claude/commands/` with the `/opsx:*` commands.
- Confirm with `openspec --version` and by checking `.claude/skills/` has content.

## Setup Step 2 — Write real project context into `openspec/config.yaml`

- Inspect the repo to infer the actual stack: `package.json` / `requirements.txt` / `go.mod` / `pom.xml` (whichever applies), the testing framework in use, the folder layout (`src/`, `app/`, etc.), and any visible convention (linter, formatter, README notes).
- Write the `context:` block describing that stack and those conventions **concretely** — no generic filler like "follow best practices."
- Add basic `rules:` for the `proposal` and `specs` artifacts (e.g. proposals must include a rollback plan, specs must use Given/When/Then). If you're unsure what rules the team wants, ask — don't invent them.
- If something isn't inferable from the repo (undocumented architecture decisions), ask before assuming.

## Setup Step 3 — Set up the backlog, shaped the way this team works

Before creating anything, **ask the user how they want the backlog organized.** Don't default silently to a single file — teams differ here and this is exactly the kind of decision that shouldn't be inferred. Present options like:

- **A. Single `BACKLOG.md`** at repo root — one flat list of items, each with a status (`todo` / `in-progress` / `done`) and, once closed, the commit hash. Simplest, works well for small teams or low volume.
- **B. `backlog/` folder split by sprint** — one file per sprint/iteration (e.g. `backlog/sprint-01.md`), same per-item schema inside each file.
- **C. `backlog/` folder split by release** — one file per release/milestone (e.g. `backlog/v1.2.0.md`).
- **D. Something else** — let them describe it.

Use `AskUserQuestion` if available so it's a clean single choice; otherwise ask directly in chat. Whatever they pick, keep the per-item schema consistent: id/title, status, the refined requirement text once step 2 of the day-to-day flow has run, and the commit hash once closed. Include one example item so the format is unambiguous.

If a backlog (in any shape) already exists, **don't reorganize it** — show its current structure and adapt to it instead of imposing a new one.

## Setup Step 4 — Create the three Trinity agents, grounded in this repo

Create three agent files (default location `.claude/agents/`; if this repo has a different convention for Claude Code agents, ask and use that instead):

- `architect.agent.md`
- `backend-developer.agent.md`
- `frontend-developer.agent.md`

Use `references/agent-templates.md` for the skeleton and exactly what each section needs. In short, each agent needs: its scoped responsibility (architect = impact + overall structure; backend = API/data/server logic; frontend = UI/state/experience), the real stack and conventions from Setup Step 2, and precise instructions for the refinement step — surface ambiguities, propose a concrete ordered solution, say whether tests are needed, write the refined requirement, ask about open decisions — **without** implementing code or touching `openspec/` at this stage.

Don't fill a section with generic placeholder content. If you don't have enough information about the repo to complete a section, ask instead of inventing it.

## Setup Step 5 — Verify or install the conventional-commit skill

Check whether a conventional-commit skill for Claude Code already exists in this repo (e.g. `.claude/skills/conventional-commit/`). Day-to-day flow steps 7 and 9 depend on it existing.

If it's missing, **install the real one from this same skill's source repo** rather than writing a generic equivalent from scratch:

```bash
npx skills add github:silvanatrabalon/my-skills/skills/conventional-commit -a claude-code
```

This is the same skill trinity-workflow itself ships from — reuse it instead of reinventing it. Only fall back to writing a simple equivalent by hand if `npx` isn't available or the install genuinely fails (e.g. no network access); tell the user which case applied.

## Setup Step 6 — Document Trinity in `CONTRIBUTING.md`

Use `references/contributing-template.md` as the base. Fill its placeholders with what was actually gathered in Steps 1-4 (real stack, real backlog shape, real agent names) — don't leave generic text in. It documents: the golden rule (never paste a raw bullet into `/opsx:propose`), the 9-step day-to-day flow above, and concrete example messages for the refinement step and for `/opsx:propose`, `/opsx:apply`, `/opsx:archive`.

If `CONTRIBUTING.md` already exists, **don't overwrite it** — show its current content and ask how to integrate this section.

## Setup Step 7 — Reference Trinity from `CLAUDE.md`

- If `CLAUDE.md` doesn't exist at repo root, create one with a short "Development Workflow" section: this repo uses the Trinity Workflow for new feature work, the golden rule (never a raw backlog bullet into `/opsx:propose`), and a pointer to `CONTRIBUTING.md` for the full flow. Keep it brief — `CONTRIBUTING.md` is the source of truth, this is just the pointer Claude Code reads automatically.
- If `CLAUDE.md` already exists, **don't rewrite it** — show its current content and ask where a short pointer section should go.

## Setup Step 8 — Final summary

Report clearly:
- What got installed, and which files were created or modified.
- What you had to infer vs. what still needs the user's manual review (e.g. confirm the stack detected in `config.yaml`, adjust an agent if the repo has particularities you couldn't infer).
- The concrete next step: add the team's first real item to the backlog and start the day-to-day flow from step 1 — not from this setup skill.

## Restrictions

- Don't implement any feature's code as part of this setup.
- Don't invent conventions, architecture decisions, or rules that aren't real or inferable from the repo — ask when unclear.
- Don't overwrite `openspec/`, the backlog (in whatever shape it already has), `CONTRIBUTING.md`, or `CLAUDE.md` if they already exist — show what's there and ask how to migrate or merge.
- Don't force the global OpenSpec install through another method if it needs admin permissions or fails — tell the user instead.

## Reference files

- `references/contributing-template.md` — full `CONTRIBUTING.md` template for the Trinity Workflow, with placeholders to fill from what this setup discovers.
- `references/agent-templates.md` — skeleton and required sections for `architect.agent.md`, `backend-developer.agent.md`, `frontend-developer.agent.md`.
