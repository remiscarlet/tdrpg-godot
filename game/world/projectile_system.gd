class_name ProjectileSystem
extends Node

@onready var projectiles_container: Node2D = $ProjectileContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func spawn(projectile_scene: PackedScene, ctx: ProjectileSpawnContext) -> ProjectileBase:
    var node := projectile_scene.instantiate()
    var projectile := node as ProjectileBase
    if projectile == null:
        push_error("Projectile scene does not inherit ProjectileBase.")
        return null

    projectiles_container.add_child(projectile)
    projectile.configure(ctx)
    return projectile