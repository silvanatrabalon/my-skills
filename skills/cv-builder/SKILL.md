---
name: cv-builder
description: Interview the user for complete CV/resume data and render it into an ATS-optimized, single-column PDF for software engineering roles. Use when the user wants to build, update, or tailor a resume/CV to a specific job posting. Not for general document formatting, cover-letter-only requests without a resume, or non-software-engineering resumes without adapting the skills taxonomy first.
---

# CV Builder

**Audience:** Software engineers building or tailoring a resume/CV for job applications.

**Goal:** Collect complete, accurate CV data through a structured interview, then render it into a PDF that follows evidence-based ATS-parsing and hiring-manager research — not a generic template filled in blind.

**Prerequisite:** `pip3 install --user reportlab` (pure Python, no external binaries — check with `python3 -c "import reportlab"` before starting; install if missing).

## Why the interview comes first

A resume is only as good as the specifics in it — vague, unquantified bullets are one of the most common mistakes hiring managers flag. Don't generate anything until you have real content for each required field. If the user gives you a thin answer, push back once with a concrete follow-up question before moving on; don't silently pad it with filler.

## Step 1: Interview

Ask progressively, grouped by section below — don't dump every question at once. Skip anything the user already gave you earlier in the conversation. Track answers against `references/cv-data-schema.md`; a required field left unanswered means you go back and ask, not guess or invent.

### 1. Target & positioning
- Target role/seniority (e.g. "Senior Backend Engineer," "Staff Full-stack"). This drives which skills and bullets get foregrounded.
- Do they have a **specific job posting** they're applying to? If yes, get the full text — Step 2 uses it for keyword tailoring. If no, build a strong general-purpose version instead.
- Primary specialization/domain in their own words.

### 2. Contact & links
Full name, email, phone (ask if they want it included — optional), city + country (never a full street address), LinkedIn, GitHub/portfolio.

### 3. Summary inputs
Total years of experience, and 1-2 sentences on what they want a hiring manager to take away first.

### 4. Work history (repeat per role, most recent first)
Company, title, location, start/end dates, 3-5 achievement bullets per recent role.

**For every bullet, apply the XYZ formula** — "Accomplished [X], measured by [Y], by doing [Z]." If a bullet has no metric, don't accept it as-is: ask what concretely changed and whether there's a number (%, time, cost, users, requests). If truly none exists, help find a defensible proxy (scope, frequency, team size) rather than leaving it unquantified. Full formula and examples in `references/content-rules.md`.

If they held multiple titles at one company, ask whether responsibilities changed significantly — that decides stacked-titles vs. separate-blocks formatting (see `references/content-rules.md`).

For roles 10+ years old or off-domain from the target role, ask if they want it compressed to one line instead of full bullets.

### 5. Skills
Have the user sort their stack into: **Languages, Frameworks & Libraries, Cloud & Infra, DevOps & Delivery, AI-Assisted Development** (adjust categories if their stack doesn't fit). Push for specific tools/services, not just the umbrella term — "AWS" alone is weaker than "AWS (EC2, Lambda, S3)". Cap ~10-15 items per category; if they list more, ask which matter most for the target role.

### 6. Education & certifications
Degree, institution, location, graduation year (optional to omit if 15+ years of experience — ask their preference). Certifications if any.

### 7. Cover letter
Ask if they want one too. Only worth drafting if it'll be genuinely tailored to one posting — see `references/content-rules.md`.

## Step 2: Keyword tailoring (only if a target job posting was given)

Read the posting. Note recurring technical terms and their acronym/full-form pairs (e.g. "CI/CD" / "Continuous Integration/Continuous Deployment"). Weave them into the summary, skills, and bullets you're already writing — only where true. Never bolt on a keyword list, and never attribute a tool/practice the user didn't actually use. Full guidance in `references/ats-rules.md`.

## Step 3: Write cv_data.json

Follow the schema in `references/cv-data-schema.md` exactly — the render script parses this structure directly. Show the user a plain-text preview of the summary and one experience block before rendering so they can catch mistakes early.

## Step 4: Render to PDF

```bash
python3 scripts/build_cv.py cv_data.json --output <name>-resume.pdf
```

The script escapes special characters, lays out a single-column document (Helvetica, the PDF-standard Arial-equivalent — no external fonts, no tables, no images/icons), and lets content flow to a second page naturally rather than forcing everything onto one page. If it errors, read the message — it means a required field is missing or malformed in `cv_data.json` — fix the JSON and rerun.

## Step 5: Self-check before handoff

Walk through the checklist at the bottom of `references/ats-rules.md`. Because the template is deterministic, a failure here means a bug in `scripts/build_cv.py`, not something to design around by hand-editing the PDF.

Then tell the user:
- Where the PDF is saved.
- To run it through [Jobscan](https://www.jobscan.co/) against the actual job posting for a match-rate score (third-party tool, not automatable here) and aim for 80%+.
- That a cover letter, if requested, comes after the resume is final and only tailored to one specific role.

## Iterating for a second job posting

Reuse the existing `cv_data.json` — don't re-run the full interview. Redo Step 2 with the new posting, adjust bullet order/skill emphasis to match, and render to a new filename (e.g. `--output name-resume-<company>.pdf`) so earlier versions survive.

---

## Reference files

- `references/ats-rules.md` — formatting constraints that keep a resume machine-parseable, keyword-matching guidance, and the Step 5 self-check checklist.
- `references/content-rules.md` — the XYZ bullet formula, skills-section rules, summary rules, page-length norms, multiple-positions-at-one-company formats, what to cut for senior profiles, and common mistakes to avoid.
- `references/cv-data-schema.md` — the exact JSON structure `scripts/build_cv.py` expects, with a full worked example.
