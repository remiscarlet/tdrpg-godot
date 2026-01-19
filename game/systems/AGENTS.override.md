# AGENTS.override.md — Runtime Systems (game/systems)

Purpose: World-level orchestration nodes (spawning, combatant lifecycle, turrets, loot, level container glue). Systems own scene containers and call into the module host to configure actors from definitions.

Dependency map:
- Inputs: definitions via `game/providers/definition_db.gd`, spawn contexts/resources under `game/definitions`, and level containers/scenes in `scenes/`.
- Outputs: instantiated actors with modules installed (`combatant_system.gd`, `turret_system.gd`), loot/indicators attached to scene graph, and tasks for controllers (e.g., `hauler_task_system.gd`).
- Relies on helpers/constants in `game/utils/*` for physics layers, IDs, and priorities.

Guidance:
- Treat systems as the only entry points for creating/despawning gameplay actors; avoid direct scene instantiation elsewhere.
- Keep system ↔ module boundaries clean: pass definitions/context into ModuleHost instead of wiring components inline.
- When adding a new system, mirror container/queue_free patterns already used for combatants and turrets to preserve lifecycle expectations.***
