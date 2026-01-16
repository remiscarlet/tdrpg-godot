class_name Hurtbox2DComponent
extends Area2D

var root: Node2D
var health: HealthComponent


func _ready() -> void:
    _activate_if_ready()


func bind_root(node: Node2D) -> void:
    root = node
    _activate_if_ready()


func bind_health_component(component: HealthComponent) -> void:
    health = component
    _activate_if_ready()


func _activate_if_ready() -> void:
    if root == null:
        return
    if health == null:
        return

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
        push_warning(
            "Hurtbox2DComponent exists without a valid associated HealthComponent! (%s)" % self,
        )

    emitter.on_hit_target(self)
