# AGENTS.override.md — Controllers (game/controllers)

Purpose: Behavior drivers that translate intent into component actions (player input, aim/fire orchestration, AI hauling logic). Controllers live under an actor’s `ControllersRoot` and expect wiring from the module system.

Dependency map:
- Inputs: references to components (inventory, interactable detector, fire weapon, target sensors) provided via modules in `game/actors/attachments_rig/modules`.
- Locomotion routing uses `NavigationAgent2D` and, for newer flows, intents from `game/locomotion`.
- Task/goal sources come from systems (e.g., `HaulerTaskSystem`) and definitions via spawn contexts.

Guidance:
- Expose explicit bind/setter methods for dependencies; avoid grabbing nodes by path at runtime.
- Keep navigation configuration (layers, avoidance) consistent with locomotion drivers and level navmaps.
- Use controllers for decision/state progression, leaving raw data/state in components and runtime systems.***
