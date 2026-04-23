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

---

## Install a skill

### Option 1 — VS Code / Cursor Extension (recommended)

Install the [Skills Manager](https://marketplace.visualstudio.com/items?itemName=SilvanaTrabalon.skills-manager) extension for a visual interface to browse, install, update, and remove skills across agents (Cursor, GitHub Copilot, Claude Code, and more).

### Option 2 — CLI

```bash
npx skills add github:silvanatrabalon/my-skills/skills/<skill-name>
```

**Examples:**

```bash
npx skills add github:silvanatrabalon/my-skills/skills/git-env-skill
npx skills add github:silvanatrabalon/my-skills/skills/excalidraw-diagram
npx skills add github:silvanatrabalon/my-skills/skills/skill-creator
npx skills add github:silvanatrabalon/my-skills/skills/skill-linter
```
