---
id: spec-create
name: Create or Update Spec
version: 0.1
last_verified: 2026-01-20
scope: repo-wide
dependencies:
  - "docs/agent/skills/doc_update.md"
outputs:
  - "docs/specs/*.md"
  - "docs/specs/index.md"
---

# Skill: Create or Update Spec

## Purpose
Create or update a specs/plans document that guides implementation for an approved ADR.

## When to Use
- The user asks to create a new spec/plan document.
- The user asks to update an existing spec/plan document (status, phases, milestones, risks, validation).

Do NOT use when:
- The request is to make a design decision (use record-design-decision).
- The request is to implement a spec (use implement-spec).

## Inputs (Required)
- Target ADR(s) or explicit confirmation that no ADR exists (use `n/a` only if none).
- Spec intent/scope (1-3 sentences).
- Current status: Draft | Active | Retired.
- Milestones and validation criteria (even if minimal placeholders).

## Outputs (Required)
- A spec file under `docs/specs/NNNN-<slug>.md`.
- `docs/specs/index.md` updated with the spec row.

## Procedure
1) Choose the next available spec number (NNNN) and a short kebab-case slug.
2) Create or update the spec using `docs/specs/TEMPLATE.md`:
   - Fill Title, Status, Linked ADR(s), Scope, Last updated.
   - Ensure Implementation phases are explicit and numbered.
   - Provide Milestones, Risks, Validation/Acceptance.
3) Update `docs/specs/index.md` with the new/updated spec row.
4) Ensure the spec links back to ADR(s) and the ADR(s) reference the spec if applicable.
5) Invoke the Documentation Updating skill (required dependency).

## Guardrails
- Keep specs lightweight and phase-driven; do not restate the ADR decision.
- Use only statuses: Draft, Active, Retired.
- Do not create spec files outside `docs/specs/`.
