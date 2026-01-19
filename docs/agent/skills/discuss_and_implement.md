---
id: discuss-and-implement
name: Discuss and Implement (Fast Path)
version: 1.0
last_verified: 2026-01-19
dependencies:
  - "docs/agent/skills/design_discussion.md"
  - "docs/agent/skills/implement_spec.md"
  - "docs/agent/skills/tdd_loop.md"
  - "docs/agent/skills/doc_update.md"
---

# Skill: Discuss and Implement (Fast Path)

## Purpose
Enable rapid execution for small features or small-scope refactors by combining:
- a disciplined (but brief) design discussion
- immediate implementation using the standard implementation + TDD workflows

This workflow intentionally SKIPS the formal “Record Decision (ADR)” step unless escalation criteria are met.

## When to Use
Use this skill when the change is:
- localized to 1–2 modules
- low-risk and reversible
- not introducing a new long-lived architectural pattern
- not changing major invariants, boundaries, or public APIs

If those conditions are not true, use the full flow:
Design → Record → Implement.

## Inputs (Required)
- Feature/problem statement
- Target area in repo (module/folder/file)
- Acceptance criteria (observable behavior)
- Constraints (performance/engine limitations, time budget, non-goals)

## Outputs (Required)
1) A **Fast Design Note** (brief, but senior-quality)
2) **User confirmation gate** (see below)
3) Code changes implemented using:
   - `docs/agent/skills/implement_spec.md`
   - and `docs/agent/skills/tdd_loop.md`
4) Documentation updates via `docs/agent/skills/doc_update.md`

## Escalation Criteria (When “Record Decision” becomes mandatory)
If ANY of the following is true, STOP and switch to:
`docs/agent/skills/record_design_decision.md` before implementing.

- New long-lived abstraction/pattern is introduced (new service/subsystem, new layering rule).
- Public API contract changes (anything other modules depend on).
- Cross-cutting refactor across multiple subsystems.
- New invariants/boundaries are introduced or changed.
- Significant performance or correctness risk (hot path changes, concurrency-like ordering constraints).
- The discussion reveals meaningful unresolved uncertainty that warrants an ADR for future readers.

## Procedure

### Phase 1 — Fast Design Discussion (Brief but rigorous)
Follow the intent of `docs/agent/skills/design_discussion.md`, but constrain output to:
- Problem (1 short paragraph)
- Scoreboard (3–5 quality attributes)
- Options (2 options minimum unless truly only one)
- Recommendation (explicit trade-offs)
- Next step (implementation plan in 3–7 bullets)

Produce the Fast Design Note using the template below.

### Phase 2 — Confirmation Gate
This workflow requires a user “go-ahead” before implementation.

- If running interactively:
  - Present the Fast Design Note and explicitly request confirmation to proceed.
  - Do not begin implementation until confirmation is received.

- If running non-interactively (one-shot agent execution):
  - Treat the user’s request to “implement” as implicit confirmation.
  - Still include the Fast Design Note before the implementation summary.

### Phase 3 — Implement Immediately (TDD-first)
Implement using:
- `docs/agent/skills/implement_spec.md`
- and the mandatory TDD loop in `docs/agent/skills/tdd_loop.md`

Constrain the first implementation slice to the smallest behavior that proves the direction.

### Phase 4 — Documentation Finalizer
Always apply:
- `docs/agent/skills/doc_update.md`

Even when skipping ADRs, update at least one of:
- a relevant context file (if vocabulary/invariants changed), OR
- a nearby `AGENTS.md` (if workflow/invariants changed locally), OR
- a short “sharp edge” note near the code (if you discovered a footgun)

## Fast Design Note Template (Required)
### Fast Design Note
- **Problem:** <what we are doing and why>
- **Scope:** <what modules/files are in scope>
- **Non-goals:** <what we are not doing>
- **Scoreboard (3–5):**
  - <attribute>: <how we judge>
- **Options:**
  - A) <option> — <1–2 sentence summary> (pros/cons in bullets)
  - B) <option> — <1–2 sentence summary> (pros/cons in bullets)
- **Recommendation:** <option + why>
- **Trade-offs accepted:** <explicit>
- **Implementation plan (3–7 bullets):**
  - <step>
  - <step>
- **Escalation check:** ADR required? (Yes/No) + <1-line justification>

## Final Response Requirements
When this skill completes (after implementation):
- Include the Fast Design Note (or link/path if written to a doc).
- Include the TDD trace (from `tdd_loop.md`).
- Include the Implementation Summary (from `implement_spec.md`).
- Include Doc Update Summary (from `doc_update.md`).

## Guardrails
- Prefer small, reversible steps; avoid structural churn.
- If uncertainty grows mid-implementation, pause and escalate to the formal Record Decision flow.
- If the fix requires touching many files, stop and reassess scope before proceeding.
