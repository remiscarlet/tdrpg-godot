# GODOT_PROJECT

Quick reference for Godot-project shape so coding agents can modify runtime safely. Keep this doc aligned with `project.godot`, root scenes, and `game/utils/constants/*`.

## Entry & Bootstrap
- Main entry: `project.godot` → `run/main_scene="uid://kk4opvtpytbu"` → `scenes/game_root.tscn`.
- `GameRoot` (`scenes/game_root.gd`) `_ready()` calls `start_run()`: creates `RunState`, binds it into `RunHUD` and `LevelSystem`, then lets `LevelSystem.start_session()` instantiate `LevelContainer`.
- `LevelContainer` (`scenes/world/level_container.tscn` + `.gd`):
  - `_ready()` resets run seed/UUID, instantiates the selected map (currently `"map01"` → `scenes/world/maps/map1.tscn`) under `MapSlot`, wires spawn signals, and spawns the player via `CombatantSystem`.
  - Binds systems: combatant, turret, ranged attack, hauler tasks, squad, and camera; connects `SpawnSystem.combatant_spawn_requested` → `CombatantSystem.spawn`.
  - Dependency injection: nodes in group `run_state_consumers` get `bind_run_state`; `combatant_system_consumers` get `bind_combatant_system` (see `game/utils/constants/groups.gd`).
- UI bootstrap: after `LevelContainer` is created, `GameRoot` binds `Minimap` to the nav root/tilemap/player coming from `LevelContainer`; HUD already bound to `RunState`.

## Autoloads (Project Settings → `[autoload]`)
| Name | Path | Type | Responsibility | Allowed to depend on |
| --- | --- | --- | --- | --- |
| `DefinitionDB` | `res://game/providers/definition_db.gd` | Node | Loads `.tres/.res` definitions for items, turrets, enemies, automatons, players, ranged attacks into dictionaries on `_ready()`. | Definition/resource classes; safe for gameplay systems to read. Avoid coupling back to scene runtime. |
| `Debug` | `res://game/debug/debug_service.gd` (`class_name DebugService`) | Node | Owns `DebugState`, selected combatant, emits debug requests (`request_force_move_squad`, selection), toggles overlay groups. | `Groups` constants; runtime nodes via signals. Keep free of game progression logic. |

## Input Map (Project Settings → `[input]`; also stored in `project.godot`)
| Action | Default binding | Semantics / usage | Notes |
| --- | --- | --- | --- |
| `move_up` | `W` | Player movement up. | Keep naming stable for movement code. |
| `move_down` | `S` | Player movement down. |  |
| `move_left` | `A` | Player movement left. |  |
| `move_right` | `D` | Player movement right. |  |
| `confirm` | `Space` | Primary confirm/accept; used by UI and in-world actions. |  |
| `turret` | `Q` | Request turret placement (used by `TurretPlacerComponent`). |  |
| `interact` | `F` | Interact/use context action. |  |
| `zoom_in` | `,` | Camera zoom in. | Camera scripts expect these names. |
| `zoom_out` | `.` | Camera zoom out. |  |
| `zoom_reset` | `/` | Reset camera zoom. |  |
Update via Godot Editor → Project Settings → Input Map. Changing names requires updating scripts listening for these actions.

## Groups & Layers
- Node group constants: `game/utils/constants/groups.gd`
  - Binding/injection: `run_state_consumers`, `combatant_system_consumers`.
  - Scene population: `combatants`, `loot`, `interactables`, `resource_collectors`, `ranged_attack`, spawn groups (`player_spawns`, `enemy1_spawns`, `enemy2_spawns`).
  - Debug overlays toggled by `DebugService`: `debug_overlay_squad`, `debug_overlay_combatant`, `debug_overlay_navigation`, `debug_overlay_selection`, `debug_overlay_heatmap`, `debug_overlay_belief`.
- Global groups declared in `project.godot [global_group]` mirror core categories: `combatants`, `loot`, `interactables`, `debug_overlay_squad`, `debug_overlay_combatant`.
- Collision / navigation layers (`project.godot [layer_names]`):
  - 2D Navigation: `layer_1=WALK`.
  - 2D Physics: `1=WORLD_SOLID`, `2=ACTOR_BODY`, `3=AREA_SENSOR`, `4=LOOT`, `5=INTERACTABLE`, `6=FLOCK`, `10-14` friendly (hurtbox/hitbox/pickup/targeting/hostile sensors), `17-21` enemy1 equivalents, `23-27` enemy2 equivalents. Keep layer meanings aligned when adding colliders/masks.

## Signals / Event Conventions
- `DebugService` signals: `state_changed`, `selection_changed`, `request_force_move_squad(squad_id, target_pos)`. Use to drive debug overlays or force-move squads.
- `SpawnSystem.combatant_spawn_requested` (map scenes) is connected to `CombatantSystem.spawn` inside `LevelContainer` during `_initialize_map()`.
- Dependency injection is group-driven: joining `run_state_consumers` or `combatant_system_consumers` opts a node into deferred binding when added to the tree under `LevelContainer`.

## Project Settings Invariants
- Renderer features: Forward Plus (`config/features` includes `"Forward Plus"`).
- Stretch: `window/stretch/mode="viewport"`, `aspect="expand"` → UI/gameplay assume viewport scaling.
- Rendering: `textures/canvas_textures/default_texture_filter=0` (nearest/pixel-perfect look).
- Main scene and autoload names/paths above are canonical; do not rename without updating `project.godot`.
- Editor plugin: `gdUnit4` enabled; keep unless test tooling is intentionally changed.

