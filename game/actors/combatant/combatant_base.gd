class_name CombatantBase
extends CharacterBody2D

var spawn_context: CombatantSpawnContext
var definition: CombatantDefinition
var level_container: LevelContainer
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
@onready var health: HealthComponent = rig.get_node("%ComponentsRoot/HealthComponent")
@onready var player_ctrl: Node = rig.get_node("%ControllersRoot/PlayerInputController")
@onready var ai_hauler_ctrl: Node = rig.get_node("%ControllersRoot/AIHaulerController")
@onready var ai_wander_ctrl: Node = rig.get_node("%ControllersRoot/AIWanderNavigationController")


# Lifecycle Methods
func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED


func _ready() -> void:
    print("== Readying CombatantBase...")

    hurtbox_collision_shape.shape = sprite_collision_shape.shape
    health.died.connect(_on_HealthComponent_died)

    var inventory_component = rig.get_node("%ComponentsRoot/InventoryComponent")
    var pickupbox_component = rig.get_node("%FacingRoot/Sensors/PickupboxComponent")
    inventory_component.configure(pickupbox_component, inventory_capacity)

    var interactable_detector_component = (
        rig.get_node(
            "%FacingRoot/Sensors/InteractableDetectorComponent",
        )
    )
    player_ctrl.bind_interactable_detector_component(interactable_detector_component)
    ai_hauler_ctrl.bind_interactable_detector_component(interactable_detector_component)
    ai_hauler_ctrl.bind_inventory_component(inventory_component)

    var aim_to_target_component = rig.get_node("%ComponentsRoot/AimToTarget2DComponent")
    var facing_root = rig.get_node("%FacingRoot")
    aim_to_target_component.bind_facing_root(facing_root)

    _set_controller(player_ctrl)

    process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(_delta: float) -> void:
    # Controllers set desired_dir; motor applies it.
    velocity = desired_dir.normalized() * move_speed
    move_and_slide()


# Public Methods
func configure_combatant_pre_ready(
        ctx: CombatantSpawnContext,
        combatant_definition: CombatantDefinition,
) -> void:
    spawn_context = ctx
    definition = combatant_definition
    global_position = ctx.origin

    if "inventory_capacity" in combatant_definition:
        inventory_capacity = combatant_definition.inventory_capacity
    move_speed = combatant_definition.move_speed
    combat_tags = combatant_definition.combat_tags

    var _rig = get_node("AttachmentsRig")
    var health_component: HealthComponent = _rig.get_node("ComponentsRoot/HealthComponent")
    health_component.set_max_health(combatant_definition.max_hp)

    var team_id = combatant_definition.team_id
    var sensors = _rig.get_node("FacingRoot/Sensors")

    var hurtbox = sensors.get_node("Hurtbox2DComponent")
    PhysicsUtils.set_hurtbox_collisions_for_team(hurtbox, team_id)
    hurtbox.set_combatant_root(self)

    var pickupbox = sensors.get_node("PickupboxComponent/PickupSensorArea")
    PhysicsUtils.set_pickupbox_collisions_for_team(pickupbox, team_id)


func configure_combatant_post_ready(container: LevelContainer) -> void:
    _bind_level_container_ref(container)
    _set_controller_by_team_id(definition.team_id)


# Helpers
func _on_HealthComponent_died(source: Node) -> void:
    print("%s killed by %s!" % [self, source])
    queue_free()


func _set_controller_by_team_id(team_id: int) -> void:
    var active
    if team_id != CombatantTeam.PLAYER:
        active = ai_wander_ctrl
    elif (self as Player) == null:
        active = ai_hauler_ctrl
    else:
        active = player_ctrl

    _set_controller(active)


func _set_controller(active: Node) -> void:
    player_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_hauler_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_wander_ctrl.process_mode = Node.PROCESS_MODE_DISABLED

    active.process_mode = Node.PROCESS_MODE_INHERIT


func _bind_level_container_ref(container: LevelContainer) -> void:
    level_container = container

    var fire: FireWeaponComponent = rig.get_node("%ComponentsRoot/FireWeaponComponent")
    fire.bind_projectile_system(level_container.get_node("%ProjectileSystem"))

    var loot: LootableComponent = rig.get_node("%ComponentsRoot/LootableComponent")
    loot.bind_loot_system(level_container.get_node("%LootSystem"))

    var ai_hauler_controller: AIHaulerController = (
        rig.get_node(
            "%ControllersRoot/AIHaulerController",
        )
    )
    ai_hauler_controller.bind_hauler_task_system(level_container.get_node("%HaulerTaskSystem"))
