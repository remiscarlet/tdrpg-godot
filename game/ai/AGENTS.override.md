# AGENTS.override.md — AI (game/ai)

Purpose: Squad/behavior frameworks and shared AI states. Current mature path is the squad runtime + FSM states; locomotion-aware states are newer and not yet wired through the module install pattern.

Dependency map:
- Squads (`ai/squads/*`) use FSM helpers in `game/fsm`, consume directives/configs from systems, and expect actors built via the module system (modules attach squad wiring when present).
- Locomotion states under `ai/states` produce `LocomotionIntent` objects for drivers in `game/locomotion` and assume a `NavigationAgent2D` on the actor.
- Debug draw hooks depend on debug utilities in `game/utils`.

Guidance:
- Favor the squad runtime + FSM for coordinated behaviors; keep them deterministic and directive-driven.
- When adding AI movement, prefer intent-based states rather than embedding navigation directly in controllers.
- If you need squad-specific rules, extend `game/ai/squads/AGENTS.override.md` rather than diverging from it.***
