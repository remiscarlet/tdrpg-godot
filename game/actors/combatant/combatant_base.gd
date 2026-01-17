class_name CombatantBase
extends CharacterBody2D

var spawn_context: CombatantSpawnContext
var definition: CombatantDefinition
var inventory_capacity: int = 1
var move_speed: float = 100.0
var combat_tags: Array[StringName] = [] # e.g. ["swarm", "armored"]
var squad_link: SquadLink
var _desired_dir: Vector2 = Vector2.ZERO
var _desired_speed_scale: float = 1.0

@onready var sprite_collision_shape: CollisionShape2D = $"CollisionShape2D"


# Lifecycle Methods
func _ready() -> void:
    process_physics_priority = 10


func _physics_process(_delta: float) -> void:
    velocity = _desired_dir.normalized() * move_speed * _desired_speed_scale
    move_and_slide()


func set_desired_move(dir: Vector2, speed_scale: float = 1.0) -> void:
    _desired_dir = dir
    _desired_speed_scale = clampf(speed_scale, 0.0, 1.0)


# Public Methods
func configure_pre_ready(
        ctx: CombatantSpawnContext,
        combatant_definition: CombatantDefinition,
) -> void:
    spawn_context = ctx
    global_position = ctx.origin

    definition = combatant_definition
    move_speed = combatant_definition.move_speed
    combat_tags = combatant_definition.combat_tags


func get_desired_dir() -> Vector2:
    return _desired_dir


func get_desired_speed_scale() -> float:
    return _desired_speed_scale
