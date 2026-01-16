class_name CombatantBase
extends CharacterBody2D

var _desired_dir: Vector2 = Vector2.ZERO

var spawn_context: CombatantSpawnContext
var definition: CombatantDefinition
var inventory_capacity: int = 1
var move_speed: float = 100.0
var combat_tags: Array[StringName] = [] # e.g. ["swarm", "armored"]

@onready var sprite_collision_shape: CollisionShape2D = $"CollisionShape2D"

# Lifecycle Methods

func _physics_process(_delta: float) -> void:
    # Controllers set _desired_dir; motor applies it.
    velocity = _desired_dir.normalized() * move_speed
    move_and_slide()

func set_desired_dir(dir: Vector2) -> void:
    _desired_dir = dir

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
