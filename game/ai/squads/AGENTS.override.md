# AGENTS.override.md — Squad AI subsystem (game/ai/squads)

Extra rules when working in squad code:

## Invariants
- Squad runtime must remain deterministic given the same inputs (avoid time-based randomness unless explicitly injected).
- Keep cohesion/slot logic independent from rendering/debug draw.
- Prefer “directive changes via method calls” (e.g., set_directive()) over raw field writes for high-level intent changes.

## Boundaries
- Do not reach into unrelated systems directly (UI, rendering, editor tooling).
- Depend on shared abstractions (e.g., FSM base, registries/services) rather than hard-coded singletons.

## Debugging hooks
- Add cheap observability: concise debug strings, small debug draw adapters, or counters.
- Avoid spamming logs per frame; prefer gated debug flags.

## What to update when behavior changes
- Update docs/agent/TDRPG_CONTEXT.md only if design intent changes.
- Update docs/agent/GODOT_GDSCRIPT_STYLE.md only if conventions change.