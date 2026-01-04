class_name CombatantBase
extends CharacterBody2D

var level_container: LevelContainer

var desired_dir: Vector2 = Vector2.ZERO

@export var move_speed: float = 200.0

@onready var sprite_collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var rig = $"AttachmentsRig"

@onready var sensors_root: Node = rig.get_node("%FacingRoot/Sensors")
@onready var hurtbox_collision_shape: CollisionShape2D = sensors_root.get_node("Hurtbox2DComponent/CollisionShape2D")

@onready var health: HealthComponent = rig.get_node("%ComponentsRoot/HealthComponent")

@onready var player_ctrl: Node = rig.get_node("%ControllersRoot/PlayerInputController")
@onready var ai_hauler_ctrl: Node = rig.get_node("%ControllersRoot/AIHaulerController")
@onready var ai_wander_ctrl: Node = rig.get_node("%ControllersRoot/AIWanderNavigationController")

@onready var bar: HealthBarView = rig.get_node("%ViewsRoot/HealthBarView")

func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED

func _ready() -> void:
    print("Reading CombatantBase...")

    hurtbox_collision_shape.shape = sprite_collision_shape.shape
    health.health_changed.connect(_on_HealthComponent_health_changed)
    health.died.connect(_on_HealthComponent_died)

    var interactable_detector_component = rig.get_node("%FacingRoot/Sensors/InteractableDetectorComponent")
    player_ctrl.bind_interactable_detector_component(interactable_detector_component)
    ai_hauler_ctrl.bind_interactable_detector_component(interactable_detector_component)

    print("Setting inventory_component pickupbox component...")
    var pickupbox_component = rig.get_node("%FacingRoot/Sensors/PickupboxComponent")
    var inventory_component = rig.get_node("%ComponentsRoot/InventoryComponent")
    inventory_component.bind_pickupbox_component(pickupbox_component)

    var aim_to_target_component = rig.get_node("%ComponentsRoot/AimToTarget2DComponent")
    var facing_root = rig.get_node("%FacingRoot")
    aim_to_target_component.bind_facing_root(facing_root)

    set_controller(player_ctrl)

    process_mode = Node.PROCESS_MODE_INHERIT

func _on_HealthComponent_health_changed(current: float, maximum: float) -> void:
    bar.set_ratio(current / maximum)
    bar.visible = current < maximum

func _on_HealthComponent_died(source: Node) -> void:
    print("%s killed by %s!" % [self, source])
    queue_free()

func set_controller_by_team_id(team_id: int) -> void:
    var active
    if team_id != CombatantTeam.PLAYER:
        active = ai_wander_ctrl
    elif (self as Player) == null:
        active = ai_hauler_ctrl
    else:
        active = player_ctrl

    set_controller(active)

func set_controller(active: Node) -> void:
    # Disable both, enable one. Disabled means no _process/_physics_process/_input, etc. :contentReference[oaicite:3]{index=3}
    player_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_hauler_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_wander_ctrl.process_mode = Node.PROCESS_MODE_DISABLED

    active.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(_delta: float) -> void:
    # Controllers set desired_dir; motor applies it.
    velocity = desired_dir.normalized() * move_speed
    move_and_slide()

func bind_level_container_ref(container: LevelContainer) -> void:
    level_container = container

    var fire: FireWeaponComponent = rig.get_node("%ComponentsRoot/FireWeaponComponent")
    fire.bind_projectile_system(level_container.get_node("%ProjectileSystem"))

    var loot: LootableComponent = rig.get_node("%ComponentsRoot/LootableComponent")
    loot.bind_loot_system(level_container.get_node("%LootSystem"))

    var ai_hauler_controller: AIHaulerController = rig.get_node("%ControllersRoot/AIHaulerController")
    ai_hauler_controller.bind_hauler_task_system(level_container.get_node("%HaulerTaskSystem"))
