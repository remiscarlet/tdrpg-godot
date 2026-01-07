class_name Hurtbox2DComponent
extends Area2D

# signal hit(damage: float, source: Node, hit_position: Vector2)

@export var health_path: NodePath
@onready var health: HealthComponent = get_node_or_null(health_path) as HealthComponent
@onready var root: Node2D = get_parent().get_parent().get_parent().get_parent() # AttachmentsRig/FacingRoot/Sensors/Hurtbox2DComponent

func _ready() -> void:
    area_entered.connect(_on_area_entered)

func _on_area_entered(other: Area2D) -> void:
    var emitter := other as DamageEmitterBase
    if emitter == null:
        # Was not a damage emitter. Skip
        return

    print("[%s] Was hit by %s" % [self, other])

    # Was damage emitter
    var payload := emitter.get_damage_payload()
    var dmg = payload.amount
    var src = payload.source

    if health:
        health.apply_damage(dmg, src)
    else:
        push_warning("Hurtbox2DComponent exists without a valid associated HealthComponent! (%s)" % self)

    emitter.on_hit_target(self)