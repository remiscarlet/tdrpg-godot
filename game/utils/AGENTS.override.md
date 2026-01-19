# AGENTS.override.md — Utilities & Constants (game/utils)

Purpose: Shared helpers, math/physics utilities, inventory primitives, navigation helpers, and central constants/enums (layers, groups, loot IDs, physics priorities).

Dependency map:
- Physics helpers (`physics_utils.gd`) supply collision layer/mask setup to components, modules, and systems; constants under `constants/` define IDs consumed across controllers/components/systems.
- Inventory/haul/nav utilities are used by controllers (hauler, aim/fire), systems (loot, spawn), and state resources.
- Debug helpers are referenced by debug draw adapters and observability hooks.

Guidance:
- Reuse constants here instead of hard-coding IDs or layers; keep new IDs in sync across related files.
- Prefer adding cross-cutting helpers here rather than embedding copies in subsystems.
- Maintain deterministic helpers (avoid hidden randomness) to keep systems reproducible.***
