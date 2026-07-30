# Content Rules

**Source:** synthesized from 2026 research on senior/staff software engineer resumes (Google recruiter guidance on the XYZ formula, Toptal/Robert Half/CoderHood hiring-manager mistake analyses, VisualCV/Resume.io on multi-position formatting, Techinterview/Scale.jobs on length norms). Use this file while running the Step 1 interview in SKILL.md and while drafting bullets — it's the "why" behind the questions the skill asks.

## The XYZ formula for every bullet

Google recruiters' formula: **"Accomplished [X], measured by [Y], by doing [Z]."**

- **X** — the outcome/impact (what got better?)
- **Y** — the metric (%, time, dollars, users, requests — how do you know it got better?)
- **Z** — the technical method (what did you actually build/change?)

Weak: "Responsible for optimizing database queries."
Strong: "Decreased database query latency by 35% by implementing composite indexing and query caching in PostgreSQL, boosting API throughput by 15%."

**During the interview**: if the user gives you an unquantified bullet ("worked on the deployment pipeline," "helped improve performance"), don't accept it silently. Ask what changed concretely and push for a number. If they genuinely have no metric, a defensible proxy is acceptable as a last resort — scope ("across 3 services"), frequency ("run on every PR"), or team size affected ("adopted by a team of 8") — but a real number is always better than a proxy.

## Senior/staff-specific framing

For a senior/staff-level bullet, especially anything architecture- or leadership-related, include: the design decision, the technical approach (name real technologies/patterns), and the measurable outcome. Open with a verb that signals ownership level — "Architected," "Designed," "Led," "Drove" — rather than "Helped with" or "Worked on," which reads as junior/IC-only even when the underlying work was substantial.

Distinguish and balance two bullet types across a senior resume:
- **IC/technical bullets**: concrete systems built or improved, with metrics.
- **Leadership bullets**: mentorship, architecture decisions, cross-team influence, technical direction-setting. Quantify these too where possible (team size mentored, number of services migrated under your design, adoption rate of a standard you introduced).

## Bullets per role

- Most recent / most relevant roles: 3–5 bullets.
- Older or less relevant roles (roughly 10+ years back, or a different domain than the target role): compress to 1 bullet or a single summary line — ask the user whether they want it compressed before dropping detail.

## Multiple positions at the same company

Two formats, pick based on how much the role actually changed:

- **Stacked titles** — same company header, multiple title/date lines beneath it, each with its own bullets. Use when responsibilities stayed largely similar across titles (e.g. a title-only promotion with no real scope change).
- **Separate blocks under one company** — same company name/location shown once, then each position gets its own title, dates, and full bullet set. Use when scope or seniority changed significantly between positions.

Either way, include one line that signals *why* the promotion happened (the achievement or skill that earned it) rather than just listing the new title.

## Resume length

- **5+ years of experience**: two pages is standard and expected — don't force everything onto one page. A senior engineer's career compressed into one dense unreadable page looks worse than two well-organized pages.
- **The rule that matters**: every line on every page must be substantive (recent achievements, relevant architecture/leadership work). If content runs past two pages, the fix is cutting low-value content per "what to cut" below — never shrinking the font or margins to force a fit.

## What to cut when experience is extensive

- Roles from 15+ years ago, unless directly relevant to the target role.
- Obsolete technologies no longer relevant to the market you're targeting.
- Early-career/junior or academic project detail once you have substantial professional experience to show instead.
- Graduation year is optional to omit once you have 15+ years of experience — ask the user's preference rather than deciding for them.

## Professional summary

3–4 sentences, placed at the top. For senior/staff engineers, lead with: level + years of experience + primary domain, and mention AI-assisted development if it's part of their actual workflow (not as a buzzword — only if true). Update this per application to match the target role's language.

Example pattern found in research: *"Staff software engineer with 11 years of experience designing planet-scale distributed systems in fintech and ads infrastructure."*

## Skills section

- Group by category: **Languages, Frameworks & Libraries, Cloud & Infra, DevOps & Delivery, AI-Assisted Development** (add/rename categories only if the user's stack doesn't fit these).
- 10–15 items per category — beyond that it reads as unfocused; ask the user to prioritize by relevance to the target role instead of listing everything they've ever touched.
- Name specific tools/services, not just the category umbrella — "AWS" alone is weaker than "AWS (EC2, Lambda, S3, CloudWatch)". Same for CI/CD ("GitHub Actions, Jenkins") and AI tools ("Claude Code, GitHub Copilot, Cursor").
- At least one experience bullet should back up each skill category with a real result — a skill that's only ever listed, never demonstrated, reads as weaker than one shown in action.

## Common mistakes to actively avoid

- Vague project descriptions ("worked on a Java web app") with no role, scope, or outcome.
- Generic job titles that don't match industry-standard naming (prefer "Backend Engineer" / "Full-stack Developer" over "Software Expert").
- Not tailoring to the specific role — same resume sent everywhere, no reordering of skills/bullets to match the posting.
- Disjointed timeline with no visible progression (junior → mid → senior → lead).
- Typos and grammar errors — proofread the final text; these disproportionately hurt trust in technical accuracy.

## Cover letter

Only worth writing if it will be genuinely tailored to one specific role — a generic cover letter is worse than none, since it signals low effort. Skip it if the application has no field for one. Draft it only after the resume is finalized, and only if the user explicitly wants one for a specific posting (ask, don't assume).
