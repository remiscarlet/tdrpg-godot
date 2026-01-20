class_name SquadSpawnRequest
extends RefCounted
## Minimal request describing what to spawn.
## This is intentionally small for v1; the goal is to create a stable contract
## between the Director/Policy layer and the Spawn Execution layer.

## Purpose: Data request to spawn a squad.
var team_id: int = -1
var squad_size: int = 0
var combatant_id: StringName = StringNames.EMPTY
# Optional selector hints (used by placement later).
var spawn_tags: Array[StringName] = []


func _init(
        p_team_id: int = -1,
        p_squad_size: int = 0,
        p_combatant_id: StringName = StringNames.EMPTY,
        p_spawn_tags: Array[StringName] = [],
) -> void:
    team_id = p_team_id
    squad_size = p_squad_size
    combatant_id = p_combatant_id
    spawn_tags = p_spawn_tags.duplicate()


func is_valid() -> bool:
    return team_id >= 0 and squad_size > 0 and combatant_id != StringNames.EMPTY
