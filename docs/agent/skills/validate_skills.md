---
id: validate-skills
name: Validate all existing skills
version: 1.0
last_verified: 2026-01-20
dependencies:
  - "docs/agent/skills/*"
---

# Skill: Validate Skills

## Purpose
Using the requirements defined in `docs/agent/skills/AGENTS.override.md`, validate all skill files follow the expected format and satisfy all constraints.

## Inputs (Required)
None - Always validate all skills under `docs/agent/skills/`

## Output
Explicitly call out any files that fail validation and prompt the user for next steps.

## Procedure
1. Check the format and content requirements in `docs/agent/skills/AGENTS.override.md`
2. For each skill file under `docs/agent/skills`, validate its contents.
3. After validating all skills conform to the spec, check `docs/agent/skills/index.md`.
4. Validate that the index is correctly synced with the directory. Ensure a 1-to-1 match of the skill catalog.
