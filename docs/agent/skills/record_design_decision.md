---
id: record-design-decision
name: Architecture / Design Decision
version: 1.0
last_verified: 2026-01-19
dependencies: ["docs/agent/skills/doc_update.md"]
outputs: ["docs/adr/*.md", "docs/architecture/*.md", "**/AGENTS*.md"]
---

# Skill: Architecture / Design Decision

## Purpose
Make architecture/design choices using a consistent format, with explicit trade-offs and durable artifacts.
This skill MUST end by invoking the Documentation Updating skill.

## When to Use
- Choosing between patterns/approaches (APIs, layering, ownership, data flow).
- Renaming or restructuring modules.
- Introducing new “first-class” concepts (resources/services/subsystems).
- Anything likely to be referenced 2+ weeks from now.

## Inputs (Required)
- Problem statement (1–3 paragraphs)
- Constraints (technical, time, engine/runtime, performance, UX)
- Non-goals (explicitly state what you are not solving)
- Success criteria (what “good” means)

## Outputs (Required)
- One ADR added/updated: `docs/adr/NNNN-<slug>.md`
- A short “Decision Summary” (for chat response)
- Documentation updates via: `docs/agent/skills/doc_update.md`

## Procedure
1. Restate the problem in precise terms (avoid vague goals).
2. List constraints and non-goals.
3. Identify 2–4 viable options.
4. Evaluate options against constraints and success criteria.
5. Select a decision (or “defer” with explicit trigger conditions).
6. Record the decision as an ADR using the template below.
7. Invoke the Documentation Updating skill (mandatory).

## ADR Template (Required)
Create/update: `docs/adr/NNNN-<slug>.md`

### Title
NNNN: <Decision title>

### Status
Proposed | Accepted | Deprecated | Superseded by NNNN

### Context
What is happening? Why are we making this decision now?

### Problem
What are we trying to solve? What pain exists?

### Drivers / Constraints
- <driver>
- <constraint>

### Options Considered
1) <Option A>
   - Pros:
   - Cons:
   - Risks:
2) <Option B>
   - Pros:
   - Cons:
   - Risks:
(etc)

### Decision
What we chose and why.

### Consequences
- Positive:
- Negative:
- Follow-ups / migration steps:

### Notes
Any sharp edges, performance notes, or verification hints.

## Decision Summary Template (Required in final response)
- Decision:
- Key reasons:
- Trade-offs accepted:
- Follow-ups:
- ADR:
- Next step:
