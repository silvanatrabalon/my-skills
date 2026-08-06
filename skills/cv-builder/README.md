# cv-builder

A skill that interviews you for your CV/resume details and renders an ATS-optimized, single-column PDF for software engineering roles — built from 2026 research on how ATS parsers actually read resumes and what hiring managers actually look for at the senior/staff level.

Unlike a plain template fill-in, the skill pushes back on weak input: unquantified bullets, vague project descriptions, and generic skill lists all get a follow-up question before anything gets written to the resume.

---

## What It Does

| Step | What happens |
|------|--------------|
| 1 | Interviews you section by section: target role, contact info, summary inputs, work history, skills, education, certifications |
| 2 | If you give it a specific job posting, extracts recurring keywords and weaves them into real bullets (never a bolted-on list) |
| 3 | Writes your answers to `cv_data.json` |
| 4 | Renders `cv_data.json` into a single-column, ATS-safe PDF via `scripts/build_cv.py` |
| 5 | Self-checks the output against the ATS rules checklist before handing it back |

Every rule the interview enforces — the XYZ bullet formula, how to format a promotion at the same company, what to cut once you have 15+ years of experience, page-length norms, etc. — is written out in `references/content-rules.md` and `references/ats-rules.md`, not just implied. Read those files if you want to see exactly what the skill is optimizing for.

---

## Prerequisites

- Python 3 with [reportlab](https://pypi.org/project/reportlab/) — pure Python, no external binaries or LaTeX toolchain required:

```bash
pip3 install --user reportlab
```

That's the only dependency. The render script produces the PDF directly (no `pdflatex`/`tectonic`/Word needed).

---

## Installation

```bash
npx skills add github:silvanatrabalon/my-skills/skills/cv-builder -a claude-code
```

Or copy the folder directly into your agent's skills directory (e.g. `.claude/skills/cv-builder`).

---

## Usage

Just ask your agent to build or update your resume:

> "Help me build my resume, I'm a Senior Full-Stack Engineer with 6 years of experience."

> "I'm applying to this job posting [paste it] — tailor my resume to it."

The skill runs the interview conversationally — it won't ask everything in one giant block, and it won't generate anything until it has real, specific answers (not "worked on backend stuff").

### Running the render script directly

Once `cv_data.json` exists (the skill writes it during the interview), you can re-render manually:

```bash
python3 scripts/build_cv.py cv_data.json --output my-resume.pdf
```

See `references/cv-data-schema.md` for the exact JSON structure, including a full worked example.

---

## Tailoring to multiple job postings

Keep the same `cv_data.json` and ask the agent to re-tailor it to a new posting — it reuses your work history and skills, adjusts keyword emphasis and bullet ordering, and renders to a new file so earlier versions aren't overwritten:

```bash
python3 scripts/build_cv.py cv_data.json --output my-resume-acme-corp.pdf
```

---

## Customizing the skills taxonomy

The default skill categories (`Languages`, `Frameworks & Libraries`, `Cloud & Infra`, `DevOps & Delivery`, `AI-Assisted Development`) are aimed at a full-stack/DevOps-leaning profile. If your stack doesn't fit — e.g. you're in mobile, data/ML, or embedded — just tell the agent during the interview and it'll use different categories; `cv_data.json`'s `skills` object accepts any category names.

---

## What you get, and what you don't

- ✅ A PDF with a real, selectable text layer — verified to extract cleanly (this is what ATS parsers actually read).
- ✅ Single column, no tables/images/icons, standard Helvetica font — the formatting choices research shows are safest across Workday/Greenhouse/Lever/iCIMS/Taleo.
- ❌ **Not** an automatic ATS match-rate score. After rendering, run the PDF through [Jobscan](https://www.jobscan.co/) against your target posting — that's a manual, third-party step the skill reminds you to do but can't automate.
- ❌ **Not** a cover letter generator by default — it'll draft one only if you ask, and only tailored to one specific posting (a generic cover letter is worse than none).

---

## File Structure

```
cv-builder/
├── SKILL.md                    # Full skill spec: interview flow, rendering steps, self-check
├── references/
│   ├── ats-rules.md            # Formatting constraints that keep a resume machine-parseable
│   ├── content-rules.md        # XYZ bullet formula, skills-section rules, page-length norms, common mistakes
│   └── cv-data-schema.md       # cv_data.json structure + full worked example
├── scripts/
│   └── build_cv.py             # Renders cv_data.json -> single-column ATS-safe PDF (reportlab)
└── README.md                   # This file
```

---

## Skill Definition

See [`SKILL.md`](./SKILL.md) for the full skill specification — trigger conditions, the exact interview questions, and the step-by-step render/self-check flow.
