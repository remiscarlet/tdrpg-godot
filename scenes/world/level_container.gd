class_name LevelContainer
extends Node2D

const Player = preload("res://scenes/player/player.gd")

var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

@onready var combatants_container: Node = $CombatantSystem/CombatantsContainer
@onready var turret_system: TurretSystem = $TurretSystem
@onready var projectile_system: ProjectileSystem = $ProjectileSystem
@onready var combatant_system: CombatantSystem = $CombatantSystem
@onready var map_slot: Node2D = $MapSlot

@export var map_content_scene: PackedScene

var map_content: Node2D

func _ready() -> void:
	assert(map_content_scene != null)

	# Instantiate the per-map content under MapSlot
	map_content = map_content_scene.instantiate() as Node2D
	map_slot.add_child(map_content)

	var spawn_system: SpawnSystem = map_slot.get_child(0).get_node("SpawnSystem")
	spawn_system.combatant_spawn_requested.connect(combatant_system.spawn)

	_bootstrap_map()

func _bootstrap_map() -> void:
	var spawn_pos := global_position

	# Prefer the "MapContent" API if present.
	if map_content is MapBase:
		var marker := (map_content as MapBase).get_player_spawn()
		if marker:
			spawn_pos = marker.global_position

	_spawn_player(spawn_pos)

func _spawn_player(spawn_pos: Vector2) -> void:
	print("Attempting to spawn player at %s" % spawn_pos)
	var ctx = CombatantSpawnContext.new(spawn_pos, Const.CombatantType.PLAYER)
	var player := combatant_system.spawn(ctx)

	var placer := player.get_node("TurretPlacer")
	placer.place_turret_requested.connect(
		func(pos, scene): turret_system.try_build_turret(player, pos, scene)
	)
