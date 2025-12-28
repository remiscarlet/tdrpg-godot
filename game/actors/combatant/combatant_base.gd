class_name CombatantBase
extends CharacterBody2D


var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload("res://scenes/projectiles/default_projectile/default_projectile.tscn")


@onready var health: HealthComponent = $HealthComponent
@onready var bar: HealthBarView = $HealthBarView


func init(projectile_system_: ProjectileSystem) -> void:
	projectile_system = projectile_system_


func _ready() -> void:
	$Hurtbox2DComponent/CollisionShape2D.shape = $CollisionShape2D.shape
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_die)


func _on_health_changed(current: float, maximum: float) -> void:
	bar.set_ratio(current / maximum)
	bar.visible = current < maximum


func _die(source: Node) -> void:
	print("%s killed by %s!" % [self, source])
	queue_free()
