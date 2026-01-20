class_name SpawnSystem
extends Node

## Purpose: System that emits combatant spawn requests.
signal combatant_spawn_requested(combatant_scene: PackedScene, ctx: CombatantSpawnContext)

@onready var spawn_sources: Node = $"../SpawnSources"
@onready var enemy1_spawn_timer: Timer = $Enemy1SpawnTimer


func _ready() -> void:
    enemy1_spawn_timer.timeout.connect(_spawn_enemy)


func get_random_player_spawn() -> Marker2D:
    return _get_group_spawns("player_spawns").pick_random()


func get_random_enemy1_spawn() -> Marker2D:
    return _get_group_spawns("enemy1_spawns").pick_random()


func get_random_enemy2_spawn() -> Marker2D:
    return _get_group_spawns("enemy2_spawns").pick_random()


func _get_group_spawns(group_name: String) -> Array[Marker2D]:
    var out: Array[Marker2D] = []
    for n in spawn_sources.find_children("*", "", true, false):
        if n.is_in_group(group_name):
            out.append(n)
    return out


func _spawn_enemy() -> void:
    var spawn = get_random_enemy1_spawn()
    var ctx = CombatantSpawnContext.new(spawn.global_position, CombatantTypes.DEFAULT_ENEMY)
    combatant_spawn_requested.emit(ctx)
