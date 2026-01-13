extends Area2D

var level_container: LevelContainer
var fire_rate_per_sec: float
var sensor_radius: float
var definition: TurretDefinition

@onready var rig = $AttachmentsRig
@onready var shot_timer: Timer = rig.get_node("%MiscRoot/ShotDelayTimer")
@onready var target_sensor_component: TargetSensor2DComponent = rig.get_node(
    "%FacingRoot/Sensors/TargetSensor2DComponent",
)
@onready var aim_controller: AimFireController = rig.get_node("%ControllersRoot/AimFireController")


# Lifecycle methods
func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    shot_timer.timeout.connect(aim_controller.try_fire)
    shot_timer.wait_time = 1 / fire_rate_per_sec

    AimFireController.wire_aim_fire_controller(self)

    var aim_to_target_component = rig.get_node("%ComponentsRoot/AimToTarget2DComponent")
    var facing_root = rig.get_node("%FacingRoot")
    aim_to_target_component.bind_facing_root(facing_root)

    process_mode = Node.PROCESS_MODE_INHERIT


# Public methods
func configure_pre_ready(container: LevelContainer, def: TurretDefinition) -> void:
    definition = def

    bind_level_container_ref(container)
    fire_rate_per_sec = def.fire_rate_per_sec
    sensor_radius = def.fire_range

    var target_sensor: TargetSensor2DComponent = get_node(
        "AttachmentsRig/%FacingRoot/Sensors/TargetSensor2DComponent",
    )
    target_sensor.set_sensor_radius(def.fire_range)


func bind_level_container_ref(container: LevelContainer) -> void:
    level_container = container

    var fire: FireWeaponComponent = get_node("AttachmentsRig/%ComponentsRoot/FireWeaponComponent")
    fire.bind_projectile_system(level_container.get_node("%ProjectileSystem"))


func configure_post_ready(world_pos: Vector2) -> void:
    bind_target_provider(ClosestTarget2DProvider.new())
    global_position = world_pos


func bind_target_provider(provider: TargetBaseProvider) -> void:
    aim_controller.bind_target_provider(provider)
