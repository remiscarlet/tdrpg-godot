class_name ProjectileBase
extends DamageEmitterBase

var speed: float = 600.0
var lifetime_s: float = 3.0

var _velocity: Vector2 = Vector2.ZERO
var _time_left: float
var _source: Node


func _ready() -> void:
    _time_left = lifetime_s
    body_entered.connect(_on_body_entered)
    damage = 10.0


func _physics_process(delta: float) -> void:
    _time_left -= delta
    if _time_left <= 0.0:
        queue_free()
        return

    global_position += _velocity * delta


func configure(ctx: ProjectileSpawnContext) -> void:
    var direction = ctx.direction.normalized()

    # Default behavior: linear shot using direction
    global_position = ctx.origin
    _velocity = direction * speed
    rotation = direction.angle()

    _source = ctx.source

    # Physics Layers
    configure_physics(ctx)

    # Tagging
    add_to_group(&"projectiles")
    if ctx.element != &"":
        add_to_group(StringName("projectiles_%s" % String(ctx.element)))


func get_damage_payload() -> DamageEvent:
    var src = _source if is_instance_valid(_source) else null
    return DamageEvent.new(damage, src)


func on_hit_target(_target: Node) -> void:
    queue_free()


func _on_body_entered(_body: Node2D) -> void:
    queue_free()


func configure_physics(ctx: ProjectileSpawnContext) -> void:
    var team_id = ctx.team_id
    if team_id == null:
        push_error("Got a ProjectileSpawnContext with no team_id set! %s" % ctx)
        return

    PhysicsUtils.set_hitbox_collisions_for_team(self, team_id)
