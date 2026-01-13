extends DamageEmitterBase
class_name BasicSword

@onready var rig: Node2D = $AttachmentsRig
@onready var facing_root: Node2D = rig.get_node("%FacingRoot")
@onready var hitbox: CollisionShape2D = $CollisionShape2D

@export var swing_range: float = 32.0
@export var start_swing_angle: float = -PI / 2
@export var end_swing_angle: float = PI / 2
@export var max_swing_duration: float = 0.3

var swinging_dur := 0.0
var is_swinging := false
var target_direction: Vector2


func get_damage_payload() -> DamageEvent:
    return DamageEvent.new(damage, self)


func on_hit_target(_source: Node) -> void:
    print("Sword hit target")


func start_swing(node: Node) -> void:
    # print("> Starting swing at %s" % node)
    is_swinging = true

    swinging_dur = 0.0
    rotation = start_swing_angle
    target_direction = global_position.direction_to(node.global_position)

    _enable_sword()


func _swing(delta: float) -> void:
    # print("> Continuing swing")
    swinging_dur += delta

    var angle_to_target := target_direction.normalized().angle()

    var swing_percentage: float = min(1.0, swinging_dur / max_swing_duration)
    var target_angle := (
        angle_to_target
        + start_swing_angle
        + (end_swing_angle - start_swing_angle) * swing_percentage
    )

    # print("[%s] swinging_dur=%s, swing_percentage=%s, target_angle=%s" % [self, swinging_dur, swing_percentage, target_angle])
    rotation = target_angle

    if swinging_dur >= max_swing_duration:
        _finish_swing()


func _finish_swing() -> void:
    # print("> Finishing swing")
    is_swinging = false
    _disable_sword()


func _process(delta: float) -> void:
    if is_swinging:
        _swing(delta)


func _ready() -> void:
    damage = 5.0
    elemental = []
    _disable_sword()


func _enable_sword() -> void:
    process_mode = Node.PROCESS_MODE_INHERIT
    visible = true
    monitoring = true


func _disable_sword() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED
    visible = false
    monitoring = false
