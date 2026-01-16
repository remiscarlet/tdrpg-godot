class_name CombatantBase
extends CharacterBody2D

var spawn_context: CombatantSpawnContext
var definition: CombatantDefinition
var desired_dir: Vector2 = Vector2.ZERO
var inventory_capacity: int = 1
var move_speed: float = 100.0
var combat_tags: Array[StringName] = [] # e.g. ["swarm", "armored"]

@onready var sprite_collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var rig = $"AttachmentsRig"
@onready var sensors_root: Node = rig.get_node("%FacingRoot/Sensors")
@onready var hurtbox_collision_shape: CollisionShape2D = (
    sensors_root.get_node(
        "Hurtbox2DComponent/CollisionShape2D",
    )
)
@onready var player_ctrl: Node = rig.get_node("%ControllersRoot/PlayerInputController")
@onready var ai_hauler_ctrl: Node = rig.get_node("%ControllersRoot/AIHaulerController")
@onready var ai_wander_ctrl: Node = rig.get_node("%ControllersRoot/AIWanderNavigationController")


# Lifecycle Methods
func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED


func _ready() -> void:
    print("== Readying CombatantBase...")

    hurtbox_collision_shape.shape = sprite_collision_shape.shape
    process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(_delta: float) -> void:
    # Controllers set desired_dir; motor applies it.
    velocity = desired_dir.normalized() * move_speed
    move_and_slide()


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
