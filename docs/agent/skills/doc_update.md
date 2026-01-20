---
id: doc-update
name: Documentation Updating
version: 1.0
last_verified: 2026-01-19
scope: repo-wide
dependencies: []
outputs: ["docs/**", "**/AGENTS*.md", "README*.md", "CHANGELOG*.md"]
---

# Skill: Documentation Updating

## Purpose
Keep architectural docs, context files, and runbooks accurate and discoverable.
This skill is a REQUIRED finalizer for architecture decisions and implementation work.

## When to Use
Use this skill when ANY of the following is true:
- You changed behavior, configuration, invariants, or boundaries.
- You introduced/renamed public concepts (types, services, modules, patterns).
- You altered how to build/test/run, or changed dependencies/tooling.
- You learned something that prevents future regressions ("sharp edge").

## Inputs (Required)
- Change summary: What changed? Why?
- Impacted areas: folders/modules
- Evidence: tests run, benchmarks, repro steps, or logs (as applicable)

## Outputs (Required)
- Updated docs/context files (as appropriate):
  - ADR (decision record) if a durable design choice was made
  - Architecture overview if system shape changed
  - Local AGENTS.md if workflow/invariants changed for a directory
  - README/update notes if usage changed
- Updated indices (if present):
  - docs/adr/index.md
  - docs/agent/skills/index.md (if skills changed)
- A short “Doc Update Summary” section in the final response (see template below)

## Decision: Where does the update live?
Choose the MINIMUM set that keeps the repo truthful:

1) Local operational rule? -> Update nearest `AGENTS.md`
   Examples: required commands, local invariants, local boundaries, do/don’t rules.

2) Durable architecture decision? -> Add/Update an ADR under `docs/adr/`
   Examples: "we use Intent/Target/Execution model", "avoidance strategy", "serialization format".

3) Human-facing usage? -> Update README / docs/architecture/*
   Examples: how to run, gameplay/system overview, diagrams.

4) Footgun/sharp edge? -> Add local note near the code + link from local AGENTS.md
   Examples: engine quirks, ordering requirements, caching caveats.

## Procedure
1. Identify impacted documentation targets (AGENTS, ADR, architecture docs, README).
2. You MUST confirm with the user what your general set of intended changes is.
3. Update the smallest doc set that makes the change discoverable at point-of-use.
4. Add/Update ADR if the change is a long-term decision (not just an implementation detail).
5. Update any indices (ADR index, architecture index).
6. Validate:
   - Links are not obviously broken.
   - Build/test commands in docs match reality.
   - Terms match code (names, paths, entrypoints).

## “Doc Update Summary” Template (Required in final response)
- Docs updated:
  - <file>: <1-line why>
  - <file>: <1-line why>
- New/updated invariants:
  - <invariant>
- Verification:
  - Ran: <commands> OR Not run: <reason>

## Anti-Patterns (Avoid)
- Writing a novel in AGENTS.md (keep it directive).
- Updating architecture docs without updating the nearest AGENTS.md pointer (discoverability).
- Recording transient implementation details as ADRs.
- Letting docs drift: if you can’t verify, say so explicitly.
