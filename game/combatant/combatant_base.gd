class_name CombatantBase
extends Area2D

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload("res://scenes/projectiles/default_projectile/default_projectile.tscn")

func init(projectile_system_: ProjectileSystem) -> void:
	projectile_system = projectile_system_