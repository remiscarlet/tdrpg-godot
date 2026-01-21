# Game Tests Mapping (game/)

Purpose: Provide a per-file test mapping for all non-trivial game scripts.
Notes:
- Constants/enums-only files and scripts with no functions are excluded as trivial.
- Debug overlay render tests are excluded; debug state/service remain in scope.
- Engine-bound suites should use tests/helpers/test_utils.gd.

## Integration hotspots
- Attachments rig + modules: wiring and stage gating (uses components/controllers).
- Locomotion driver + flock detector: navigation/physics timing and avoidance.
- Squad system + spawn manager: system-level orchestration with nav + timers.
- Director + spawn policies: observation queue and directive issuance flow.
- Ranged attacks + lootables: DefinitionDB autoload, physics groups, and signals.

## Mapping
| file | test path | scope | notes |
| --- | --- | --- | --- |
| `game/actors/attachments_rig/attachments_rig.gd` | `tests/unit/game/actors/attachments_rig/attachments_rig_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/module_host.gd` | `tests/unit/game/actors/attachments_rig/module_host_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/ai_enemy_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/ai_enemy_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/ai_hauler_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/ai_hauler_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/aim_fire_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/aim_fire_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/damageable_core_module.gd` | `tests/unit/game/actors/attachments_rig/modules/damageable_core_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/feature_module_base.gd` | `tests/unit/game/actors/attachments_rig/modules/feature_module_base_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/interactable_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/interactable_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/inventory_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/inventory_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/locomotion_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/locomotion_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/melee_attack_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/melee_attack_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/player_mouse_aiming_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/player_mouse_aiming_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/ranged_attack_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/ranged_attack_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/squad_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/squad_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/modules/turret_autofire_wiring_module.gd` | `tests/unit/game/actors/attachments_rig/modules/turret_autofire_wiring_module_test.gd` | unit | actor data/wiring |
| `game/actors/attachments_rig/rig_context.gd` | `tests/unit/game/actors/attachments_rig/rig_context_test.gd` | unit | actor data/wiring |
| `game/actors/combatant/attachments_root.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/actors/combatant/combatant_base.gd` | `tests/unit/game/actors/combatant/combatant_base_test.gd` | unit | character body; movement integration later |
| `game/actors/combatant/combatant_spawn_context.gd` | `tests/unit/game/actors/combatant/combatant_spawn_context_test.gd` | unit | actor data/wiring |
| `game/actors/damage_emitter/damage_emitter_base.gd` | `tests/unit/game/actors/damage_emitter/damage_emitter_base_test.gd` | unit | actor data/wiring |
| `game/actors/interactable/interactable_base.gd` | `tests/unit/game/actors/interactable/interactable_base_test.gd` | unit | actor data/wiring |
| `game/actors/loot/entries/loot_entry.gd` | `tests/unit/game/actors/loot/entries/loot_entry_test.gd` | unit | actor data/wiring |
| `game/actors/loot/entries/nothing.gd` | `tests/unit/game/actors/loot/entries/nothing_test.gd` | unit | actor data/wiring |
| `game/actors/loot/loot_context.gd` | `tests/unit/game/actors/loot/loot_context_test.gd` | unit | actor data/wiring |
| `game/actors/loot/loot_drop.gd` | `tests/unit/game/actors/loot/loot_drop_test.gd` | unit | actor data/wiring |
| `game/actors/loot/loot_entry_table.gd` | `tests/unit/game/actors/loot/loot_entry_table_test.gd` | unit | actor data/wiring |
| `game/actors/loot/loot_table.gd` | `tests/unit/game/actors/loot/loot_table_test.gd` | unit | actor data/wiring |
| `game/actors/loot/lootable_base.gd` | `tests/integration/game/actors/loot/lootable_base_test.gd` | integration | scene + DefinitionDB |
| `game/actors/loot/lootable_spawn_context.gd` | `tests/unit/game/actors/loot/lootable_spawn_context_test.gd` | unit | actor data/wiring |
| `game/actors/ranged_attack/ranged_attack_base.gd` | `tests/integration/game/actors/ranged_attack/ranged_attack_base_test.gd` | integration | physics + DefinitionDB |
| `game/actors/ranged_attack/ranged_attack_spawn_context.gd` | `tests/unit/game/actors/ranged_attack/ranged_attack_spawn_context_test.gd` | unit | actor data/wiring |
| `game/ai/director/belief_debug_overlay.gd` | `n/a` | excluded | debug render overlay |
| `game/ai/director/belief_map.gd` | `tests/unit/game/ai/director/belief_map_test.gd` | unit |  |
| `game/ai/director/director.gd` | `tests/unit/game/ai/director/director_test.gd` | unit |  |
| `game/ai/director/director_config.gd` | `tests/unit/game/ai/director/director_config_test.gd` | unit |  |
| `game/ai/director/director_debug_overlay.gd` | `n/a` | excluded | debug render overlay |
| `game/ai/director/director_directive.gd` | `tests/unit/game/ai/director/director_directive_test.gd` | unit |  |
| `game/ai/director/director_observation_event.gd` | `tests/unit/game/ai/director/director_observation_event_test.gd` | unit |  |
| `game/ai/director/director_state.gd` | `tests/unit/game/ai/director/director_state_test.gd` | unit |  |
| `game/ai/director/heat_map.gd` | `tests/unit/game/ai/director/heat_map_test.gd` | unit |  |
| `game/ai/squads/spawning/marker_group_spawn_placement.gd` | `tests/integration/game/ai/squads/spawning/marker_group_spawn_placement_test.gd` | integration | scene tree groups |
| `game/ai/squads/spawning/max_squads_spawn_policy.gd` | `tests/unit/game/ai/squads/spawning/max_squads_spawn_policy_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_placement.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_placement_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_placement_context.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_placement_context_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_placement_result.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_placement_result_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_point.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_point_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_policy.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_policy_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_policy_context.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_policy_context_test.gd` | unit | squad data/resources |
| `game/ai/squads/spawning/squad_spawn_request.gd` | `tests/unit/game/ai/squads/spawning/squad_spawn_request_test.gd` | unit | squad data/resources |
| `game/ai/squads/squad.gd` | `tests/unit/game/ai/squads/squad_test.gd` | unit | slot logic; add nav integration later |
| `game/ai/squads/squad_config.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/ai/squads/squad_debug_draw.gd` | `n/a` | excluded | debug render overlay |
| `game/ai/squads/squad_directive.gd` | `tests/unit/game/ai/squads/squad_directive_test.gd` | unit | squad data/resources |
| `game/ai/squads/squad_link.gd` | `tests/unit/game/ai/squads/squad_link_test.gd` | unit | squad data/resources |
| `game/ai/squads/squad_runtime.gd` | `tests/unit/game/ai/squads/squad_runtime_test.gd` | unit | squad data/resources |
| `game/ai/squads/squad_spawn_manager.gd` | `tests/integration/game/ai/squads/squad_spawn_manager_test.gd` | integration | node orchestration |
| `game/ai/squads/squad_system.gd` | `tests/integration/game/ai/squads/squad_system_test.gd` | integration | node orchestration |
| `game/ai/states/follow_directive_state.gd` | `tests/integration/game/ai/states/follow_directive_state_test.gd` | integration | AI state with driver/body |
| `game/ai/states/locomotion_intent_state_base.gd` | `tests/integration/game/ai/states/locomotion_intent_state_base_test.gd` | integration | AI state with driver/body |
| `game/ai/states/return_to_slot_state.gd` | `tests/integration/game/ai/states/return_to_slot_state_test.gd` | integration | AI state with driver/body |
| `game/ai/states/return_to_spawner_state.gd` | `tests/integration/game/ai/states/return_to_spawner_state_test.gd` | integration | AI state with driver/body |
| `game/ai/states/wander_state.gd` | `tests/integration/game/ai/states/wander_state_test.gd` | integration | AI state with driver/body |
| `game/ai/supervisor/combatant/combatant_ai_context.gd` | `tests/integration/game/ai/supervisor/combatant/combatant_ai_context_test.gd` | integration | AI supervisor + nav |
| `game/ai/supervisor/combatant/combatant_ai_debug_draw.gd` | `n/a` | excluded | debug render overlay |
| `game/ai/supervisor/combatant/combatant_ai_supervisor.gd` | `tests/integration/game/ai/supervisor/combatant/combatant_ai_supervisor_test.gd` | integration | AI supervisor + nav |
| `game/components/aim_to_target_2d/aim_to_target_2d_component.gd` | `tests/unit/game/components/aim_to_target_2d/aim_to_target_2d_component_test.gd` | unit | component state/signals |
| `game/components/fire_weapon/fire_weapon_component.gd` | `tests/unit/game/components/fire_weapon/fire_weapon_component_test.gd` | unit | component state/signals |
| `game/components/health/health_bar_view.gd` | `tests/unit/game/components/health/health_bar_view_test.gd` | unit | component state/signals |
| `game/components/health/health_component.gd` | `tests/unit/game/components/health/health_component_test.gd` | unit | component state/signals |
| `game/components/hurtbox_2d/hurtbox_2d_component.gd` | `tests/integration/game/components/hurtbox_2d/hurtbox_2d_component_test.gd` | integration | Area2D collisions |
| `game/components/interactable_detector/interactable_detector_component.gd` | `tests/integration/game/components/interactable_detector/interactable_detector_component_test.gd` | integration | Area2D collisions |
| `game/components/inventory/inventory_component.gd` | `tests/unit/game/components/inventory/inventory_component_test.gd` | unit | component state/signals |
| `game/components/lootable/lootable_component.gd` | `tests/unit/game/components/lootable/lootable_component_test.gd` | unit | component state/signals |
| `game/components/melee_attack/melee_attack_component.gd` | `tests/unit/game/components/melee_attack/melee_attack_component_test.gd` | unit | component state/signals |
| `game/components/pickupbox/pickupbox_component.gd` | `tests/integration/game/components/pickupbox/pickupbox_component_test.gd` | integration | Area2D collisions |
| `game/components/player_sighting_detector/player_sighting_detector.gd` | `tests/integration/game/components/player_sighting_detector/player_sighting_detector_test.gd` | integration | Area2D collisions |
| `game/components/target_sensor_2d/target_sensor_2d_component.gd` | `tests/integration/game/components/target_sensor_2d/target_sensor_2d_component_test.gd` | integration | Area2D collisions |
| `game/controllers/ai_hauler/ai_hauler_controller.gd` | `tests/unit/game/controllers/ai_hauler/ai_hauler_controller_test.gd` | unit | engine-bound controller logic |
| `game/controllers/aim_fire/aim_fire_controller.gd` | `tests/unit/game/controllers/aim_fire/aim_fire_controller_test.gd` | unit | engine-bound controller logic |
| `game/controllers/aim_fire/aiming_target_result.gd` | `tests/unit/game/controllers/aim_fire/aiming_target_result_test.gd` | unit | engine-bound controller logic |
| `game/controllers/player_input/player_input_controller.gd` | `tests/unit/game/controllers/player_input/player_input_controller_test.gd` | unit | engine-bound controller logic |
| `game/debug/debug_selection_draw.gd` | `n/a` | excluded | debug render overlay |
| `game/debug/debug_service.gd` | `tests/unit/game/debug/debug_service_test.gd` | unit | core debug state/service |
| `game/debug/debug_state.gd` | `tests/unit/game/debug/debug_state_test.gd` | unit | core debug state/service |
| `game/definitions/attack_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/automaton_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/combatant_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/definition_base.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/enemy_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/item_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/player_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/ranged_attack_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/shot_modes/shot_mode_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/shot_modes/single_shot_mode.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/shot_modes/spread_shot_mode.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/definitions/turret_definition.gd` | `n/a` | excluded | trivial (no funcs) |
| `game/detectors/area_candidate_detector_base.gd` | `tests/unit/game/detectors/area_candidate_detector_base_test.gd` | unit |  |
| `game/events/damage_event.gd` | `tests/unit/game/events/damage_event_test.gd` | unit | data event |
| `game/fsm/finite_state_machine.gd` | `tests/unit/game/fsm/finite_state_machine_test.gd` | unit | state machine logic |
| `game/fsm/fsm_state.gd` | `tests/unit/game/fsm/fsm_state_test.gd` | unit | state machine logic |
| `game/fsm/squad/squad_state_base.gd` | `tests/unit/game/fsm/squad/squad_state_base_test.gd` | unit | state machine logic |
| `game/fsm/squad/squad_state_hold.gd` | `tests/unit/game/fsm/squad/squad_state_hold_test.gd` | unit | state machine logic |
| `game/fsm/squad/squad_state_move_to.gd` | `tests/unit/game/fsm/squad/squad_state_move_to_test.gd` | unit | state machine logic |
| `game/fsm/squad/squad_state_patrol.gd` | `tests/unit/game/fsm/squad/squad_state_patrol_test.gd` | unit | state machine logic |
| `game/locomotion/common_intents.gd` | `tests/unit/game/locomotion/common_intents_test.gd` | unit | pure helpers |
| `game/locomotion/flock_detector.gd` | `tests/integration/game/locomotion/flock_detector_test.gd` | integration | nav/physics |
| `game/locomotion/goal_providers.gd` | `tests/unit/game/locomotion/goal_providers_test.gd` | unit | pure helpers |
| `game/locomotion/locomotion_intent.gd` | `tests/unit/game/locomotion/locomotion_intent_test.gd` | unit | pure helpers |
| `game/locomotion/nav_intent_locomotion_driver.gd` | `tests/integration/game/locomotion/nav_intent_locomotion_driver_test.gd` | integration | nav/physics |
| `game/providers/definition_db.gd` | `tests/integration/game/providers/definition_db_test.gd` | integration | autoload resources |
| `game/providers/targeting/closest_target_2d_provider.gd` | `tests/unit/game/providers/targeting/closest_target_2d_provider_test.gd` | unit | provider helpers |
| `game/providers/targeting/mouse_target_provider.gd` | `tests/unit/game/providers/targeting/mouse_target_provider_test.gd` | unit | provider helpers |
| `game/providers/targeting/target_base_provider.gd` | `tests/unit/game/providers/targeting/target_base_provider_test.gd` | unit | provider helpers |
| `game/state/meta_state.gd` | `tests/unit/game/state/meta_state_test.gd` | unit | state resource logic |
| `game/state/run_state.gd` | `tests/unit/game/state/run_state_test.gd` | unit | state resource logic |
| `game/systems/combatant_system.gd` | `tests/integration/game/systems/combatant_system_test.gd` | integration | system orchestration |
| `game/systems/hauler_task_system.gd` | `tests/integration/game/systems/hauler_task_system_test.gd` | integration | system orchestration |
| `game/systems/level_system.gd` | `tests/integration/game/systems/level_system_test.gd` | integration | system orchestration |
| `game/systems/loot_system.gd` | `tests/integration/game/systems/loot_system_test.gd` | integration | system orchestration |
| `game/systems/overhead_indicator_system.gd` | `tests/integration/game/systems/overhead_indicator_system_test.gd` | integration | system orchestration |
| `game/systems/ranged_attack_system.gd` | `tests/integration/game/systems/ranged_attack_system_test.gd` | integration | system orchestration |
| `game/systems/spawn_system.gd` | `tests/integration/game/systems/spawn_system_test.gd` | integration | system orchestration |
| `game/systems/turret_system.gd` | `tests/integration/game/systems/turret_system_test.gd` | integration | system orchestration |
| `game/utils/constants/attachment_modules.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/combatant_types.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/currencies.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/debug_flags.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/groups.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/inputs.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/layers.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/locomotion_intents.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/loot.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/physics_priorities.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/ranged_attack_types.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/squad_fsm_keys.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/string_names.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/tile_custom_data.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/turret_types.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/constants/ui.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/debug_utils.gd` | `tests/unit/game/utils/debug_utils_test.gd` | unit | utility helpers |
| `game/utils/enums/combatant_team.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/enums/rebake_cadence.gd` | `n/a` | excluded | trivial constants/enums |
| `game/utils/haul_task.gd` | `tests/unit/game/utils/haul_task_test.gd` | unit | utility helpers |
| `game/utils/inventory.gd` | `tests/unit/game/utils/inventory_test.gd` | unit | utility helpers |
| `game/utils/mouse_utils.gd` | `tests/integration/game/utils/mouse_utils_test.gd` | integration | engine helpers |
| `game/utils/nav_utils.gd` | `tests/integration/game/utils/nav_utils_test.gd` | integration | engine helpers |
| `game/utils/physics_utils.gd` | `tests/unit/game/utils/physics_utils_test.gd` | unit | utility helpers |
| `game/utils/uuid.gd` | `tests/unit/game/utils/uuid_test.gd` | unit | utility helpers |