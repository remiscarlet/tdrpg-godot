# AGENTS.override.md — LLM Coding Agent "Skills"

Workflows and runbooks describing specificpredefined flows.

## Instructions
- Skills are a first-class concept in this project. Correctness is not optional.
- All skills MUST follow a specific format. See below.
- Whenever updating a skill, you MUST verify that the format is correct and references to other files or skills are valid.
- All skills MUST describe their expected inputs and outputs, even if it's "None". 
- Dependency graphs should be considered.
    - If Skill A requires Skill B and Skill B requires Skill C, requiring Skill A from Skill X should understand that it also needs B and C.

## Skills Format
All skills must have a header with the following fields:
| Field name | Is Optional | Description |
|------------|-------------|-------------|
| `id`       | False       | `skill-name-slug` |
| `name`     | False       | Human readable one-liner describing the skill |
| `version`  | False       | Version tracking. Update this any time the contents of the file change. |
| `last_verified` | False  | The last date a human verified this skill as working. You must have human confirmation before updating this field |
| `dependencies`  | False  | A bullet list of other skills this skill relies on. It may be an empty list, but must be explicit. |
| `outputs`       | True   | Optional field describing files or directories this skill will modify |

Example:
```
---
id: doc-update
name: Documentation Updating
version: 1.0
last_verified: 2026-01-19
scope: repo-wide
dependencies: []
outputs: ["docs/**", "**/AGENTS*.md", "README*.md", "CHANGELOG*.md"]
---
```
