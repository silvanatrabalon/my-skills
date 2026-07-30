# ATS Formatting Rules

**Source:** synthesized from 2026 research across Jobscan, Resumly, JobShinobi, RecruitBPM, and hiring-manager guides. These are the constraints that keep a resume machine-parseable. The bundled template (`scripts/build_cv.py`) already implements all of them — this file exists so you can (a) explain choices to the user and (b) verify Step 5 of SKILL.md instead of guessing.

## Why this matters

Most ATS parsers read a resume linearly, left to right, top to bottom, to extract structured fields (name, contact, work history, skills). Anything that isn't a plain top-to-bottom text flow risks being mis-read, scrambled, or silently dropped — often without the candidate ever knowing why they got filtered out before a human saw the resume.

## Hard rules (never violate these)

| Rule | Why |
|------|-----|
| Single-column layout, top-to-bottom flow | Multi-column and two-column designs (e.g. Deedy-style resumes) get read straight across the page by many parsers, mashing unrelated content into gibberish. |
| No tables | ATS often skips or mangles content inside table cells. |
| No text boxes | Some ATS ignore floating text boxes entirely — contact info placed in one can become invisible to the system. |
| No icons replacing text | An icon next to a phone number is fine (decorative); an icon *instead of* the word is not — the parser needs actual text. |
| No images/graphics carrying information | Anything not in the PDF's text layer (a skill-level graphic, a headshot with a title baked in) is invisible to the ATS. |
| No headers/footers for key content | Some parsers skip header/footer regions entirely. Keep contact info, work history, and skills in the document body. |
| PDF output, not scanned/flattened image | The output must have a real, selectable text layer. A photographed or flattened PDF has no extractable text at all. |

## Strong defaults

- **File format**: PDF. It preserves formatting more reliably across ATS platforms than .docx, unless a specific application explicitly requires Word.
- **Font**: a standard, widely-supported font. Calibri and Arial are the two safest choices in current parsing studies; the bundled template uses Helvetica (the PDF-standard equivalent of Arial, requires no font embedding). Avoid decorative, script, or condensed fonts.
- **Font size**: 10–12pt for body text, 14–16pt for name/section headers.
- **Skills separators**: commas, bullets (•), or vertical bars (`|`) — never a table or grid.

## Keyword matching (when a target job posting is available)

1. Read the posting and note recurring technical terms — both the acronym and the spelled-out form (e.g. "CI/CD" and "Continuous Integration/Continuous Deployment"), since some ATS match on exact strings.
2. Weave keywords into real accomplishment sentences in the summary, skills, and experience sections — never as a bare appended list. A keyword with no supporting evidence in the bullet reads as stuffing to both the ATS relevance score and to a human reviewer.
3. Distribute keywords across multiple sections rather than concentrating them in one place.
4. Never claim a tool, language, or practice the candidate didn't actually use, even if it's in the posting.

## Validating the result (manual, third-party — not automatable by this skill)

Recommend the user run the finished PDF through [Jobscan](https://www.jobscan.co/) against the actual job posting text. It reports a match-rate percentage, missing keywords, and formatting flags. Target 80%+ match rate. This is a manual step the user does after this skill produces the PDF — there's no API to script it.

## Step-5 self-check checklist

Before handing off the PDF, confirm:

- [ ] Single column, no tables, no text boxes, no images
- [ ] Standard font (Helvetica/Arial-equivalent), 10–12pt body
- [ ] Contact info, work history, and skills are all in the document body (not header/footer)
- [ ] Output is a real PDF with selectable text (open it and try to select/copy a line of text)
- [ ] If a target posting was provided, keywords appear inside real sentences, not as a bolted-on list

Because the template is deterministic, a failure here means the template itself has a bug — fix `scripts/build_cv.py`, don't work around it by hand-editing the PDF.
