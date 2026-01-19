# AGENTS.override.md — Providers (game/providers)

Purpose: Content/data accessors (DefinitionDB) and targeting sources used by gameplay systems and controllers.

Dependency map:
- DefinitionDB loads resources from `assets/definitions/*` and supplies typed definitions to `game/systems/*` and modules during spawn.
- Targeting providers under `targeting/` expose input/mouse/closest-target lookups for controllers and weapons; depend on sensors/components under `game/components`.
- Consumers emit high-level IDs/targets rather than raw scene paths, keeping content concerns out of controllers.

Guidance:
- Route all definition lookups through DefinitionDB; do not bypass it with manual `load()` calls.
- Extend targeting via provider subclasses instead of embedding targeting heuristics into weapons/controllers.
- Keep provider APIs stateless/pure where possible so systems can swap them without cross-wiring.***
