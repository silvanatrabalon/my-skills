# cv_data.json Schema

This is the exact structure `scripts/build_cv.py` expects. Build it from the Step 1 interview answers in SKILL.md, save it as `cv_data.json`, then render.

All free-text fields are plain text — do not pre-escape LaTeX/HTML/XML characters, the script handles escaping.

```json
{
  "name": "Ada Lovelace",
  "target_title": "Senior Full-Stack Engineer",
  "contact": {
    "email": "ada@example.com",
    "phone": "+54 9 11 1234 5678",
    "location": "Buenos Aires, Argentina",
    "linkedin": "linkedin.com/in/adalovelace",
    "github": "github.com/adalovelace",
    "portfolio": "adalovelace.dev"
  },
  "summary": "Senior full-stack engineer with 8+ years of experience building and scaling distributed systems. Specializes in CI/CD automation, AWS infrastructure, and AI-assisted development workflows. Track record of leading migrations that cut deployment time and mentoring engineers into senior roles.",
  "skills": {
    "Languages": ["TypeScript", "Python", "Go"],
    "Frameworks & Libraries": ["React", "Node.js", "Django"],
    "Cloud & Infra": ["AWS (EC2, Lambda, S3, CloudWatch)", "Terraform", "Docker"],
    "DevOps & Delivery": ["GitHub Actions", "Jenkins", "Spec-driven development"],
    "AI-Assisted Development": ["Claude Code", "GitHub Copilot", "Cursor"]
  },
  "experience": [
    {
      "company": "Acme Corp",
      "location": "Remote",
      "positions": [
        {
          "title": "Senior Software Engineer",
          "start": "Jan 2022",
          "end": "Present",
          "bullets": [
            "Reduced deployment time 40% by architecting a GitHub Actions CI/CD pipeline with AWS CodeDeploy across 12 microservices",
            "Led adoption of spec-driven development across a 6-engineer team, cutting rework from mismatched requirements by half"
          ]
        },
        {
          "title": "Software Engineer",
          "start": "Jan 2019",
          "end": "Dec 2021",
          "bullets": [
            "Built a full-stack billing dashboard in React/Node.js used by 5,000+ monthly active customers"
          ]
        }
      ]
    }
  ],
  "education": [
    {
      "degree": "B.Sc. in Computer Science",
      "institution": "Universidad de Buenos Aires",
      "location": "Buenos Aires, Argentina",
      "year": "2015"
    }
  ],
  "languages": ["Spanish (Native)", "English (B2+)"],
  "certifications": [
    "AWS Certified Solutions Architect – Associate"
  ]
}
```

## Field notes

| Field | Required | Notes |
|-------|----------|-------|
| `name` | yes | |
| `target_title` | no | Shown under the name if provided (e.g. "Senior Full-Stack Engineer"). Omit to skip the line entirely. |
| `contact.email` | yes | |
| `contact.phone` | no | Ask the user whether to include it — some regions/roles skip it. |
| `contact.location` | yes | City + country only. Never a full street address. |
| `contact.linkedin` / `contact.github` / `contact.portfolio` | no, but strongly recommended for SWE | Plain domain+path is fine, script doesn't require `https://`. |
| `summary` | yes | 3-4 sentences, single string. |
| `skills` | yes | Object of category name → array of strings. Use the five standard categories from `content-rules.md` unless the user's stack needs different ones. Order in the JSON is the order rendered. |
| `experience` | yes | Array, most recent company first. |
| `experience[].positions` | yes | Array, most recent position first. A single-entry array is a normal one-title role; multiple entries render as stacked titles under one company header — see `content-rules.md` for when to use which. |
| `education` | yes | Array. Omit `year` (drop the key, don't set it to empty string) if the user chose not to disclose graduation year. |
| `languages` | no | Array of `"Language (Level)"` strings, rendered as one line under Education. Useful when the resume language isn't the candidate's native language (e.g. an EN resume for a non-native speaker) — omit if not relevant. |
| `certifications` | no | Omit the key entirely if there are none — don't pass an empty array (the script only renders the section if the key is present and non-empty). |

## Empty/optional section behavior

The script only renders a section heading if the corresponding key is present and non-empty. To omit a whole section (e.g. no certifications), delete the key from the JSON rather than setting it to `null` or `[]`.
