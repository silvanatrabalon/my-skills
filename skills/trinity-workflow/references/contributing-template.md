# CONTRIBUTING.md template — Trinity Workflow section

Fill every `{{placeholder}}` with what Setup Steps 1-4 actually discovered about this repo. Don't leave a placeholder unfilled or generic — if something wasn't discoverable, go back and ask the user rather than writing filler here.

If `CONTRIBUTING.md` already has other sections, add this as a new section rather than replacing the file.

---

```markdown
## Development Workflow: Trinity Workflow

This repository builds every new feature through the **Trinity Workflow**: OpenSpec
(spec-driven development) plus a prior backlog-refinement step using agents tuned
to this project's real stack and conventions.

### The golden rule

**Never paste a raw backlog bullet directly into `/opsx:propose`.** A raw item like
"{{example_raw_backlog_bullet}}" is ambiguous enough that the generated proposal will
have real gaps — decisions get made implicitly by whatever the model assumes, instead
of explicitly by the team. Refine it first (step 2 below); only the refined version
goes into `/opsx:propose`.

Why: the model can implement almost anything, but acts blind if it starts from an
ambiguous bullet. The Trinity agents plus this refinement step give it the project's
real context before it acts. OpenSpec is the explicit-rules world the model then moves
through precisely.

### The 9 steps

1. **Read the item** from {{backlog_location}}.
2. **Refine it in chat** with the agent that fits the item — {{architect_agent_name}}
   for cross-cutting/structural work, {{backend_agent_name}} for API/data/server logic,
   {{frontend_agent_name}} for UI/state/experience. No code changes and no `openspec/`
   edits at this step — any suggestion from the agent gets written back into
   {{backlog_location}}.
3. **Create the proposal** with `/opsx:propose`, using the refined requirement from
   step 2 — never the original bullet.
4. **Review the proposal** (proposal, design, tasks) before applying anything.
5. **Apply the change** with `/opsx:apply`. It must finish with all tests passing.
6. **Review the implementation** manually and/or by running the test suite.
7. **Commit**: confirm the spec's tasks are actually done, use the
   `conventional-commit` skill for the message, and update {{backlog_location}} with
   the item's status and the commit hash.
8. **Archive** the change with `/opsx:archive` — only once the feature is finished
   and stable, not right after step 7.
9. **Commit the archive** as the final step.

### Example messages

**Refining a backlog item (step 2):**

> I have this backlog item: "{{example_raw_backlog_bullet}}". Before I touch OpenSpec,
> help me refine it — what's ambiguous here, what's a concrete ordered solution given
> how {{project_name}} is built, do we need new tests, and what decisions are still
> open that I should confirm before proposing this?

**Creating the proposal (step 3), after refinement:**

> /opsx:propose {{example_refined_requirement}}

**Applying the change (step 5):**

> /opsx:apply — implement this proposal and make sure all tests pass before you
> finish.

**Archiving (step 8), only once stable:**

> /opsx:archive — this feature has been in production/stable for {{stability_window}}
> with no issues, archive it.

### Where things live

| Artifact | Location |
|---|---|
| Backlog | {{backlog_location}} |
| OpenSpec proposals/specs | `openspec/` |
| Refinement agents | {{agents_location}} |
| Conventional commit rules | {{conventional_commit_skill_location}} |
```
