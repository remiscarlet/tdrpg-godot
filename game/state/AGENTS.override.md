# AGENTS.override.md — Game State (game/state)

Purpose: Lightweight resources representing session/meta state (`RunState`, `MetaState`), including inventory, currencies, flags, and hub/sector progress.

Dependency map:
- Mutated by systems/controllers that award loot or consume items; uses inventory helpers in `game/utils/inventory.gd` and loot IDs in `game/utils/constants/loot.gd`.
- Signals (`state_changed`, `currency_changed`, `inventory_changed`) are consumed by UI and systems (e.g., loot/hauler flows) to react to state changes.
- Run identity (rng_seed, started_unix) feeds procedural systems and spawning contexts.

Guidance:
- Use provided helpers (`add_currency`, `consume_item`, `reset_for_new_run`) rather than directly mutating dictionaries.
- Emit/observe signals for UI or gameplay reactions; avoid coupling state resources directly to scene nodes.
- Keep new persistent fields minimal and documented; align IDs with constants/enums to avoid drift.***
