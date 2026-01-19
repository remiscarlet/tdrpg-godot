---
id: implement-spec
name: Implement Specification
version: 1.1
dependencies:
  - "docs/agent/skills/doc_update.md"
  - "docs/agent/skills/tdd_loop.md"
---

# Skill: Implement Spec

## Purpose
Implement a change based on an approved ADR/spec with verification and minimal drift.

## Inputs (Required)
You must have a specific ADR or spec file to use this workflow.
If you do not receive a file, confirm if the user wants to run the `docs/agent/skills/design_and_implement.md` skill instead.

## Output
Code implementation of the spec and updated documentation and context files.

## Mandatory Workflow
Follow `docs/agent/skills/tdd_loop.md` unless an explicit exemption applies.
If an exemption applies, record it and compensate with the strongest available verification.

## Procedure
1. Read ADR/spec; restate acceptance criteria.
2. Identify impacted modules/boundaries.
3. Invoke TDD Loop:
   - Use the smallest tests that prove the behavior.
4. Verify against acceptance criteria and authoritative checks.
5. Invoke Documentation Updating skill (mandatory).
