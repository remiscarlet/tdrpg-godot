extends Area2D

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload(
	"res://scenes/projectiles/default_projectile/default_projectile.tscn"
)
@onready var shot_timer: Timer = $ShotDelayTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shot_timer.timeout.connect(fire_turret)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotation = _get_target_pos().normalized().angle()


func fire_turret() -> void:
	var ctx = ProjectileSpawnContext.new(self, global_position, Const.TEAM_PLAYER)
	ctx.direction = _get_target_pos()
	projectile_system.spawn(projectile_scene, ctx)


func init(_projectile_system: ProjectileSystem) -> void:
	projectile_system = _projectile_system


func _get_target_pos() -> Vector2:
	return MouseUtils.get_dir_to_mouse(self)
