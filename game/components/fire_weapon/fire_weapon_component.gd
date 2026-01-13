class_name FireWeaponComponent
extends Node2D

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload(
    "res://scenes/projectiles/default_projectile/default_projectile.tscn"
)


func fire(direction: Vector2) -> bool:
    var ctx = ProjectileSpawnContext.new(self, global_position, CombatantTeam.PLAYER)
    ctx.direction = direction
    var proj = projectile_system.spawn(projectile_scene, ctx) as ProjectileBase
    return proj != null


func bind_projectile_system(system: ProjectileSystem) -> void:
    projectile_system = system
