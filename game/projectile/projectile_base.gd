class_name ProjectileBase
extends Area2D

@export var speed: float = 800.0
@export var damage: float = 10.0
@export var lifetime_s: float = 3.0

var _velocity: Vector2 = Vector2.ZERO
var _time_left: float

func _ready() -> void:
    _time_left = lifetime_s

func configure(ctx: ProjectileSpawnContext) -> void:
    # Default behavior: linear shot using direction
    global_position = ctx.origin
    _velocity = ctx.direction.normalized() * speed

    # Optional tagging (useful for “delete all fire projectiles” mechanics)
    add_to_group(&"projectiles")
    if ctx.element != &"":
        add_to_group(StringName("projectiles_%s" % String(ctx.element)))

func _physics_process(delta: float) -> void:
    _time_left -= delta
    if _time_left <= 0.0:
        queue_free()
        return

    global_position += _velocity * delta