class_name CombatantBase
extends CharacterBody2D

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload("res://scenes/projectiles/default_projectile/default_projectile.tscn")

func init(projectile_system_: ProjectileSystem) -> void:
	projectile_system = projectile_system_

func _ready() -> void:
	print($Hurtbox2DComponent)
	print($Hurtbox2DComponent/CollisionShape2D)
	print($CollisionShape2D)
	$Hurtbox2DComponent/CollisionShape2D.shape = $CollisionShape2D.shape
