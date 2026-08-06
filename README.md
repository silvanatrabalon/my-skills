# my-skills

A collection of reusable AI skills for Claude.

---

## Skills

| Skill | Description |
|-------|-------------|
| [`git-env-skill`](./skills/git-env-skill) | Set up a new Git identity environment — repos folder, per-identity gitconfig, SSH Host alias, and optional key generation. |
| [`excalidraw-diagram`](./skills/excalidraw-diagram) | Create Excalidraw diagram JSON files that make visual arguments from workflows, architectures, or concepts. |
| [`skill-creator`](./skills/skill-creator) | Create new skills from scratch, improve existing ones, run evals, and benchmark skill performance. |
| [`skill-linter`](./skills/skill-linter) | Validate skills against the agentskills.io specification — frontmatter, structure, line limits, and content quality rules. |
| [`cv-builder`](./skills/cv-builder) | Interview the user for CV/resume data and render an ATS-optimized, single-column PDF for software engineering roles, tailored to a target job posting. |
| [`trinity-workflow`](./skills/trinity-workflow) | Bootstrap the Trinity Workflow in a repo for the first time: OpenSpec + project-tuned backlog-refinement agents, so every feature goes through a reviewed proposal before implementation. |
| [`open-pull-request`](./skills/open-pull-request) | Push the current branch and open a well-structured GitHub pull request via `gh`, with a consistent title format and a body that always answers what changed and how to test it. |
| [`run-tests`](./skills/run-tests) | Run tests at the right scope — full suite, workspace, directory, or single file — with the correct command across Node, Python, Go, and Rust. |

---

## Install a skill

### Option 1 — VS Code / Cursor Extension (recommended)

Install the [Skills Manager](https://marketplace.visualstudio.com/items?itemName=SilvanaTrabalon.skills-manager) extension for a visual interface to browse, install, update, and remove skills across agents (Cursor, GitHub Copilot, Claude Code, and more).

### Option 2 — CLI

```bash
npx skills add github:silvanatrabalon/my-skills/skills/<skill-name> -a claude-code
```

Always pass `-a claude-code` — without it, the installer prompts for (or defaults to)
a generic `.agents/skills/` location instead of writing straight to `.claude/skills/`.

**Examples:**

```bash
npx skills add github:silvanatrabalon/my-skills/skills/git-env-skill -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/excalidraw-diagram -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/skill-creator -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/skill-linter -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/cv-builder -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/trinity-workflow -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/open-pull-request -a claude-code
npx skills add github:silvanatrabalon/my-skills/skills/run-tests -a claude-code
```
