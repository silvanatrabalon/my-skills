#!/usr/bin/env python3
"""Render cv_data.json into an ATS-safe, single-column PDF resume.

Usage:
    python3 build_cv.py cv_data.json [--output name-resume.pdf]

Design rules (see ../references/ats-rules.md for the research behind each one):
- Single column, top-to-bottom flow. No tables, no text boxes, no images/icons.
- Helvetica throughout (the PDF-standard equivalent of Arial) — no external font files.
- Real, selectable text layer (reportlab always produces this; never rasterize).
- Section order: Header -> Summary -> Skills -> Experience -> Education -> Certifications.
"""

import argparse
import json
import re
import sys
from pathlib import Path
from xml.sax.saxutils import escape as xml_escape

from reportlab.lib.colors import HexColor, black
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import HRFlowable, Paragraph, SimpleDocTemplate, Spacer

DARK_GRAY = HexColor("#333333")
RULE_GRAY = HexColor("#999999")

REQUIRED_TOP_LEVEL = ["name", "contact", "summary", "skills", "experience", "education"]
REQUIRED_CONTACT = ["email", "location"]


def esc(text):
    """Escape text for reportlab's paragraph mini-markup (XML-based)."""
    if text is None:
        return ""
    return xml_escape(str(text))


def slugify(name):
    slug = re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")
    return slug or "resume"


def validate(data):
    missing = [f for f in REQUIRED_TOP_LEVEL if f not in data]
    if missing:
        raise ValueError(f"cv_data.json is missing required top-level field(s): {missing}")
    contact_missing = [f for f in REQUIRED_CONTACT if f not in data.get("contact", {})]
    if contact_missing:
        raise ValueError(f"cv_data.json 'contact' is missing required field(s): {contact_missing}")
    if not data["skills"]:
        raise ValueError("cv_data.json 'skills' must have at least one category")
    if not data["experience"]:
        raise ValueError("cv_data.json 'experience' must have at least one entry")
    if not data["education"]:
        raise ValueError("cv_data.json 'education' must have at least one entry")


def build_styles():
    styles = {}
    styles["name"] = ParagraphStyle(
        "name", fontName="Helvetica-Bold", fontSize=18, leading=21,
        alignment=TA_CENTER, textColor=black, spaceAfter=2,
    )
    styles["target_title"] = ParagraphStyle(
        "target_title", fontName="Helvetica", fontSize=11.5, leading=14,
        alignment=TA_CENTER, textColor=DARK_GRAY, spaceAfter=4,
    )
    styles["contact"] = ParagraphStyle(
        "contact", fontName="Helvetica", fontSize=9.5, leading=12,
        alignment=TA_CENTER, textColor=DARK_GRAY, spaceAfter=6,
    )
    styles["section_header"] = ParagraphStyle(
        "section_header", fontName="Helvetica-Bold", fontSize=12, leading=14,
        alignment=TA_LEFT, textColor=black, spaceBefore=10, spaceAfter=3,
    )
    styles["body"] = ParagraphStyle(
        "body", fontName="Helvetica", fontSize=10.2, leading=13,
        alignment=TA_LEFT, textColor=black, spaceAfter=4,
    )
    styles["bullet"] = ParagraphStyle(
        "bullet", parent=styles["body"], leftIndent=14, spaceAfter=2,
    )
    styles["entry_header"] = ParagraphStyle(
        "entry_header", parent=styles["body"], spaceBefore=4, spaceAfter=2,
    )
    styles["sub_entry_header"] = ParagraphStyle(
        "sub_entry_header", parent=styles["body"], leftIndent=6, spaceBefore=3, spaceAfter=1,
    )
    return styles


def section_rule():
    return HRFlowable(width="100%", thickness=0.75, color=RULE_GRAY, spaceAfter=6)


def build_header(data, styles):
    flow = [Paragraph(esc(data["name"]), styles["name"])]
    if data.get("target_title"):
        flow.append(Paragraph(esc(data["target_title"]), styles["target_title"]))
    contact = data["contact"]
    parts = []
    for key in ("location", "email", "phone", "linkedin", "github", "portfolio"):
        value = contact.get(key)
        if value:
            parts.append(esc(value))
    flow.append(Paragraph(" &nbsp;|&nbsp; ".join(parts), styles["contact"]))
    flow.append(section_rule())
    return flow


def build_summary(data, styles):
    return [
        Paragraph("SUMMARY", styles["section_header"]),
        section_rule(),
        Paragraph(esc(data["summary"]), styles["body"]),
    ]


def build_skills(data, styles):
    flow = [Paragraph("SKILLS", styles["section_header"]), section_rule()]
    for category, items in data["skills"].items():
        if not items:
            continue
        line = f"<b>{esc(category)}:</b> {esc(', '.join(items))}"
        flow.append(Paragraph(line, styles["body"]))
    return flow


def build_experience(data, styles):
    flow = [Paragraph("EXPERIENCE", styles["section_header"]), section_rule()]
    for job in data["experience"]:
        company = esc(job["company"])
        location = esc(job.get("location", ""))
        positions = job["positions"]

        if len(positions) == 1:
            pos = positions[0]
            header = f"<b>{esc(pos['title'])}, {company}</b>"
            if location:
                header += f" — {location}"
            header += f" &nbsp;({esc(pos['start'])} – {esc(pos['end'])})"
            flow.append(Paragraph(header, styles["entry_header"]))
            for bullet in pos["bullets"]:
                flow.append(Paragraph(f"• {esc(bullet)}", styles["bullet"]))
        else:
            company_header = f"<b>{company}</b>"
            if location:
                company_header += f" — {location}"
            flow.append(Paragraph(company_header, styles["entry_header"]))
            for pos in positions:
                sub_header = f"<b>{esc(pos['title'])}</b> ({esc(pos['start'])} – {esc(pos['end'])})"
                flow.append(Paragraph(sub_header, styles["sub_entry_header"]))
                for bullet in pos["bullets"]:
                    flow.append(Paragraph(f"• {esc(bullet)}", styles["bullet"]))
    return flow


def build_education(data, styles):
    flow = [Paragraph("EDUCATION", styles["section_header"]), section_rule()]
    for edu in data["education"]:
        line = f"<b>{esc(edu['degree'])}</b>, {esc(edu['institution'])}"
        if edu.get("location"):
            line += f" — {esc(edu['location'])}"
        if edu.get("year"):
            line += f" &nbsp;({esc(edu['year'])})"
        flow.append(Paragraph(line, styles["body"]))
    languages = data.get("languages")
    if languages:
        flow.append(Paragraph(f"<b>Languages:</b> {esc(', '.join(languages))}", styles["body"]))
    return flow


def build_certifications(data, styles):
    certs = data.get("certifications")
    if not certs:
        return []
    flow = [Paragraph("CERTIFICATIONS", styles["section_header"]), section_rule()]
    for cert in certs:
        flow.append(Paragraph(f"• {esc(cert)}", styles["bullet"]))
    return flow


def render(data, output_path):
    styles = build_styles()
    doc = SimpleDocTemplate(
        str(output_path),
        pagesize=LETTER,
        leftMargin=0.65 * inch,
        rightMargin=0.65 * inch,
        topMargin=0.55 * inch,
        bottomMargin=0.55 * inch,
        title=f"{data['name']} - Resume",
    )
    story = []
    story += build_header(data, styles)
    story += build_summary(data, styles)
    story.append(Spacer(1, 4))
    story += build_skills(data, styles)
    story.append(Spacer(1, 4))
    story += build_experience(data, styles)
    story.append(Spacer(1, 4))
    story += build_education(data, styles)
    cert_flow = build_certifications(data, styles)
    if cert_flow:
        story.append(Spacer(1, 4))
        story += cert_flow
    doc.build(story)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="Path to cv_data.json")
    parser.add_argument("--output", help="Output PDF path (default: <slugified-name>-resume.pdf)")
    args = parser.parse_args()

    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: input file not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    data = json.loads(input_path.read_text())
    try:
        validate(data)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    output_path = Path(args.output) if args.output else input_path.parent / f"{slugify(data['name'])}-resume.pdf"
    render(data, output_path)
    print(f"Wrote {output_path}")


if __name__ == "__main__":
    main()
