class_name ProjectileSystem
extends Node

@onready var projectiles_container: Node2D = $ProjectileContainer

func spawn(projectile_scene: PackedScene, ctx: ProjectileSpawnContext) -> ProjectileBase:
    var node := projectile_scene.instantiate()
    var projectile := node as ProjectileBase
    if projectile == null:
        push_error("Projectile scene does not inherit ProjectileBase.")
        return null

    projectiles_container.add_child(projectile)
    projectile.configure(ctx)
    return projectile