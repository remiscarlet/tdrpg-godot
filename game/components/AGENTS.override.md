# AGENTS.override.md — Components (game/components)

Purpose: Reusable gameplay building blocks (health, inventory, targeting sensors, combat emitters, pickups) meant to live under an actor’s `ComponentsRoot` and be wired by the module system.

Dependency map:
- Consumed by `game/actors/attachments_rig` modules and `game/systems/*` during spawn.
- Physics/team behavior depends on masks from `game/utils/physics_utils.gd` and constants in `game/utils/constants/*`.
- Some components surface view scenes (e.g., health bar) used by UI/indicators in `game/systems/overhead_indicator_system.gd`.

Guidance:
- Keep components self‑contained with signals for state changes; avoid reaching into controllers or systems directly.
- Prefer configuration via definitions (`DefinitionBase` fields) passed through modules rather than hard‑coding values.
- Maintain collision/channel expectations (hitbox/hurtbox/pickupbox/sensor) in sync with `PhysicsUtils` helpers.***
