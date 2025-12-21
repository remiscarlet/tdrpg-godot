extends Node2D

var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

@onready var players: Node = $Players
@onready var turret_system: Node = $TurretSystem
@onready var projectile_system: Node = $ProjectileSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    spawn_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func spawn_player() -> void:
    var player := player_scene.instantiate()
    player.init(projectile_system)
    players.add_child(player)

    var placer := player.get_node("TurretPlacer")
    placer.place_turret_requested.connect(
        func(pos, scene): turret_system.try_build_turret(player, pos, scene)
    )
