### Title
0002: Introduce specs/plans document type for implementation phases

### Status
Accepted

### Context
ADRs capture durable architectural decisions, but they are too static for stepwise implementation planning. Implementation work often needs a structured, high-level plan with phases, milestones, risks, and validation that can evolve without rewriting the decision record. The repo currently lacks a first-class place for these technical design documents.

### Problem
We need a lightweight, in-repo artifact to describe concrete implementation plans for approved features/ADRs, including phases and acceptance criteria, while keeping ADRs stable as decision logs.

### Drivers / Constraints
- Keep ADRs stable and succinct as decision records.
- Provide clear, actionable implementation guidance (phases, milestones, validation).
- Maintain traceability between decisions and plans.
- Low ceremony; easy to author and update.
- Discoverable via a repo-local index.

### Options Considered
1) Extend ADRs with embedded "Implementation Plan" sections
   - Pros: Single artifact, no new directories
   - Cons: Blurs decision vs evolving plan; ADR churn; status signaling awkward
   - Risks: Stale plan sections mislead readers

2) Create a dedicated specs/plans doc type with its own index (Chosen)
   - Pros: Separates decision (ADR) from implementation plan; plans can evolve without altering decisions; clearer lifecycle (Draft/Active/Retired)
   - Cons: Another doc surface to maintain; requires index hygiene
   - Risks: Specs could drift from ADRs if links are missing

3) Rely on external trackers for plans
   - Pros: Zero repo churn
   - Cons: Loses repo-first discoverability; inconsistent quality; dependency on external tool access
   - Risks: Plans become inaccessible or lost after ticket closure

### Decision
Adopt a dedicated `docs/specs/` directory for implementation plan documents, each named `NNNN-<slug>.md`, tracked in `docs/specs/index.md`. Specs include required metadata (Title, Status, Linked ADR(s), Scope, Implementation Phases, Milestones, Risks, Validation/Acceptance) and use statuses Draft/Active/Retired. Specs must explicitly enumerate implementation phases.

### Consequences
- Positive:
  - Preserves ADR stability while enabling evolving technical plans.
  - Improves traceability from decision to execution steps.
  - Provides consistent metadata for scope and validation.
- Negative:
  - Additional index maintenance overhead.
  - Another artifact type to keep in sync with ADRs.
- Follow-ups / migration steps:
  - Create spec template and index under `docs/specs/`.
  - Update AGENTS/context docs to define when to use specs vs ADRs.
  - Add a skill for creating/updating specs (pending).

### Notes
- Status taxonomy: Draft (in progress), Active (approved and guiding work), Retired (superseded/complete; keep for history).
- Specs must link back to their driving ADR(s) and should be updated as phases complete.
