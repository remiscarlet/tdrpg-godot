# AGENTS.override.md — Locomotion (game/locomotion)

Purpose: Intent-based movement utilities (locomotion intents, goal providers, navigation-driven driver) for steering actors via `NavigationAgent2D` with optional avoidance and slowdown semantics.

Dependency map:
- Consumed by controllers/AI states in `game/controllers` and `game/ai/states` to express goals; outputs desired move vectors to `CombatantBase` motors.
- Depends on navigation setup in scenes and physics priorities/constants in `game/utils/constants/physics_priorities.gd`.
- Not yet wired through the module system; current adopters set bindings manually.

Guidance:
- Represent movement desires as `LocomotionIntent` instances and feed them through `NavIntentLocomotionDriver`; avoid per-controller pathfinding code.
- Preserve repath/slowdown parameters from intents; do not bypass the driver’s gating/avoidance unless necessary for a specific actor type.
- When integrating new actors, prefer adding a driver node + intent plumbing rather than duplicating navigation logic inside controllers.***
