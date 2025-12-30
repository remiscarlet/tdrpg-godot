class_name CombatantBase
extends CharacterBody2D

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload(
	"res://scenes/projectiles/default_projectile/default_projectile.tscn"
)

@onready var health: HealthComponent = $HealthComponent
@onready var bar: HealthBarView = $HealthBarView
@onready var hurtbox_collision_shape = $Hurtbox2DComponent/CollisionShape2D
@onready var sprite_collision_shape = $BodyShape


func init(_projectile_system: ProjectileSystem) -> void:
	projectile_system = _projectile_system


func _ready() -> void:
	hurtbox_collision_shape.shape = sprite_collision_shape.shape
	health.health_changed.connect(_on_health_changed)
	health.died.connect(on_die)


func _on_health_changed(current: float, maximum: float) -> void:
	bar.set_ratio(current / maximum)
	bar.visible = current < maximum


func on_die(source: Node) -> void:
	print("%s killed by %s!" % [self, source])
	queue_free()
