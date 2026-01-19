# AGENTS.override.md — Attachments Rig (game/actors/attachments_rig)

Purpose: Canonical composition layer for actors. The rig exposes slot roots (components, controllers, facing, views, misc) and a `ModuleHost` that installs feature modules during spawn. Prefer adding behavior via modules instead of hand‑wiring nodes in scenes.

Dependency map:
- Inputs: spawn contexts/definitions from `game/systems` (`configure_pre_tree` / `configure_post_ready`), team IDs, and per‑actor definitions in `assets/definitions/*`.
- Modules live in `modules/` and depend on components in `game/components` and controllers in `game/controllers`.
- Outputs: configured actor nodes ready for gameplay systems (combat, loot, AI) and physics masks from `game/utils/physics_utils.gd`.

Guidance:
- Create new features as `FeatureModuleBase` subclasses and register them in `ModuleHost._modules`; keep install logic stage‑aware (PRE_TREE/READY/POST_READY).
- Keep wiring/data plumbing in modules; avoid duplicating that work inside scenes or controllers.
- Modules should tolerate missing optional nodes (use rig accessors) and avoid pulling in unrelated systems directly.***
