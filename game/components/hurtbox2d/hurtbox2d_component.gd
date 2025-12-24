class_name Hurtbox2DComponent
extends Area2D

signal hit(damage: float, source: Node, hit_position: Vector2)

# Optional: keep a reference to Health if you want direct wiring.
@export var health_path: NodePath 
@onready var health: HealthComponent = get_node_or_null(health_path) as HealthComponent

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area2D) -> void:
    var proj := other as ProjectileBase
    if proj == null:
        # only handle Projectile collisions
        return

    var payload := proj.get_damage_payload()
    var dmg = payload.amount
    var src = payload.source

    hit.emit(dmg, src, global_position)

    # Option A: Hurtbox applies damage directly if wired.
    if health:
        health.apply_damage(dmg, src)