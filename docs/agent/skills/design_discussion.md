---
id: design-discussion
name: Discuss Design
version: 1.0
last_verified: 2026-01-19
dependencies:
  - "docs/agent/skills/record_design_decision.md"
  - "docs/agent/skills/doc_update.md"
outputs:
  - "Design Discussion Note (in chat or doc)"
  - "Clear next step: decide / prototype / spike / defer"
---

# Skill: Discuss Design

## Purpose
Run a high-quality architecture discussion that clarifies trade-offs, constraints, risks, and migration paths.
This skill is discussion-first: it does NOT assume a decision has been made.

If/when the discussion converges, transition to:
- `docs/agent/skills/record_design_decision.md` (record the decision)
- then `docs/agent/skills/doc_update.md` (update canonical docs)

## When to Use
Use this skill when:
- You are evaluating architectural patterns or subsystem boundaries.
- You need to resolve ambiguity in a design direction.
- The “right” answer depends on constraints (performance, UX feel, iteration speed, engine constraints).
- There are multiple plausible options and you want a disciplined analysis.

Do NOT use this skill for:
- straightforward implementation tasks (use implement flow)
- pure bugfixes with known cause (use bug triage flow)

## Inputs (Preferred)
Provide as many as are already known; if unknown, make reasonable assumptions and label them.

- Problem statement (what needs to change / be enabled)
- Context: where in the codebase this lives (modules, key types, workflows)
- Constraints: engine limitations, performance targets, save/load, determinism, dev velocity, etc.
- Non-goals: what is explicitly out of scope
- Success criteria: what “good” looks like (behavior + maintenance + performance)
- Risk tolerance: how much complexity is acceptable right now

## Outputs (Required)
A “Design Discussion Note” containing:
1) Problem framing and constraints
2) Quality attributes (the “scoreboard”)
3) Options (at least 2 unless genuinely only one exists)
4) Trade-offs + risks + failure modes
5) Recommendation and why
6) Next step (decide / prototype / spike / defer) with explicit acceptance criteria

If the discussion concludes with a durable decision:
- Proceed to `record_design_decision.md` and create/update an ADR (mandatory)
- Then run `doc_update.md` (mandatory)

## Senior-Level Discussion Standards
This discussion must explicitly address:

- Boundaries and ownership:
  - Which module owns the behavior? Which modules must not know about it?
  - What APIs become stable contracts?

- Invariants and lifecycle:
  - What must always be true? What are acceptable temporary states?
  - Initialization order, teardown, hot-reload behaviors (esp. Godot autoloads/singletons)

- Failure modes:
  - How does it fail? What does “safe failure” look like?
  - Debuggability: logs, debug overlays, repro hooks

- Performance shape:
  - Hot paths vs cold paths
  - Algorithmic scaling (O(n), O(n log n)) and constants (allocation churn)
  - Frequency (per frame/tick vs event-driven)

- Evolution and migration:
  - How do we migrate from current architecture to the new one?
  - Can we stage it behind flags/adapters?
  - How do we avoid “big bang” rewrites?

- Testing and verification:
  - What tests/repro harnesses validate correctness?
  - Where are the seams that make testing possible?

- Ergonomics and complexity budget:
  - How easy is it to use correctly?
  - How hard is it to misuse?
  - What cognitive load does it impose on future changes?

## Procedure
1) Frame the problem
   - Restate the ask in concrete terms.
   - Identify what is changing vs what must remain stable.

2) Gather constraints and non-goals
   - Pull relevant invariants from `docs/agent/context/*` and local `AGENTS.md`.
   - List explicit non-goals.

3) Define the scoreboard (quality attributes)
   Use a short list (3–6) that will drive the decision.
   Examples: correctness, iteration speed, performance, determinism, clarity, extensibility.

4) Enumerate options (2–4)
   - Include at least one “minimal change” option.
   - Include at least one “clean architecture” option (even if too heavy right now).
   - Include at least one “prototype/spike” option if uncertainty is high.

5) Evaluate options
   For each option, analyze:
   - API surface and ownership boundaries
   - Failure modes and debug strategy
   - Performance characteristics
   - Migration plan
   - Testing approach
   - Complexity cost

6) Recommend a path and define next step
   - Pick an option OR propose a spike with crisp acceptance criteria.
   - If “spike”, define what evidence will decide (benchmarks, prototype, UX feel test).
   - If “decide now”, proceed to `record_design_decision.md`.

## Design Discussion Note Template (Required)
### Problem
- What we are trying to achieve:
- What must remain true (invariants):
- What is explicitly out of scope (non-goals):

### Context
- Where this lives (modules/files):
- Key abstractions involved:
- Current pain / failure cases:

### Constraints
- Engine/runtime constraints:
- Performance constraints:
- Timeline / complexity budget:

### Scoreboard (Quality Attributes)
- <Attribute>: why it matters, how we’ll judge it
- <Attribute>: ...

### Options
#### Option A — <name>
- Summary:
- Ownership/boundaries:
- Pros:
- Cons:
- Failure modes:
- Performance shape:
- Testing approach:
- Migration plan:
- Risks / unknowns:

#### Option B — <name>
(same fields)

(Optional) Option C — <name>

### Recommendation
- Recommended option:
- Why this wins given the scoreboard:
- Trade-offs we are consciously accepting:

### Next Step
Choose one:
- **Decide now:** proceed to `docs/agent/skills/record_design_decision.md`
- **Spike/prototype:** define:
  - What to build:
  - Success criteria:
  - Time/effort box:
  - What result would change our mind:
- **Defer:** define trigger conditions and what we need to learn first

### Open Questions
- <question>
- <question>

## Guardrails (Avoid)
- Avoid “future perfect” architecture that blocks shipping.
- Avoid “big bang rewrites” unless there is a compelling migration plan.
- Avoid premature generality: prefer composable seams over frameworks.
- Avoid inventing constraints; if unknown, label assumptions explicitly.
