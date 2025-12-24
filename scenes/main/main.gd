extends Node2D

const Player = preload("res://scenes/player/player.gd")

var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

@onready var combatants_container: Node = $CombatantSystem/CombatantsContainer
@onready var turret_system: TurretSystem = $TurretSystem
@onready var projectile_system: ProjectileSystem = $ProjectileSystem
@onready var combatant_system: CombatantSystem = $CombatantSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player()

func spawn_player() -> void:
	var ctx = CombatantSpawnContext.new(global_position, projectile_system)
	var player := combatant_system.spawn(player_scene, ctx)

	print(player)
	print(player as Player)

	var placer := player.get_node("TurretPlacer")
	placer.place_turret_requested.connect(
		func(pos, scene): turret_system.try_build_turret(player, pos, scene)
	)
