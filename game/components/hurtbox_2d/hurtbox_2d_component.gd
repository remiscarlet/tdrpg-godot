class_name Hurtbox2DComponent
extends Area2D

# signal hit(damage: float, source: Node, hit_position: Vector2)
@export var health_path: NodePath

var root: CombatantBase

@onready var health: HealthComponent = get_node_or_null(health_path) as HealthComponent


func _ready() -> void:
    _activate_if_possible()


func set_combatant_root(combatant: CombatantBase) -> void:
    root = combatant
    _activate_if_possible()


func _activate_if_possible() -> void:
    if root == null:
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
