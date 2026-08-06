# explore

A skill that turns the agent into a thinking partner — for exploring ideas, investigating a messy problem, or comparing options — before any code gets written. Not a fixed workflow: no required steps, no mandatory output.

---

## What It Does

| Situation | What the agent does |
|---|---|
| Vague idea ("thinking about real-time collab") | Sketches the space, asks where the user's head is at |
| Messy existing system ("the auth system is a mess") | Reads the codebase, diagrams the current flow, asks which tangle is burning |
| Stuck mid-implementation | Traces what's involved, explores paths, offers to capture the decision or add a spike |
| Comparing options ("Postgres or SQLite?") | Pushes for context first, then builds a constraint-driven comparison |

Uses ASCII diagrams liberally — state machines, architecture sketches, comparison tables — to make thinking visible instead of walls of prose.

**Hard rule: never writes application code or edits files in this mode.** If the user asks to implement something, the agent reminds them to exit explore mode first. Capturing a crystallized decision as a spec or ADR is fine — that's capturing thinking, not implementing — but the skill never does this without the user asking.

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/explore -a claude-code
```

`-a claude-code` targets Claude Code specifically — without it, the installer prompts for (or falls back to) a generic `.agents/skills/` location instead of `.claude/skills/`.

---

## Usage

Just bring a problem, in your own words:

> "I'm thinking about adding real-time collaboration, not sure where to start"
> "the auth system is a mess, help me think through it"
> "should we use Postgres or SQLite for this?"
> "I'm stuck, the OAuth integration turned out way more complex than expected"

The agent explores with you — asking questions, reading the codebase, sketching diagrams — without touching a single file, until you're ready to move to implementation (at which point, exit explore mode).
