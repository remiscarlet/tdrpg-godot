extends Area2D

var level_container: LevelContainer

@onready var rig = $AttachmentsRig
@onready var shot_timer: Timer = rig.get_node("%MiscRoot/ShotDelayTimer")

@onready var aim_controller: AimFireController = rig.get_node("%ControllersRoot/AimFireController")

func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_DISABLED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    shot_timer.timeout.connect(aim_controller.try_fire)

    AimFireController.wire_aim_fire_controller(self)

    var aim_to_target_component = rig.get_node("%ComponentsRoot/AimToTarget2DComponent")
    var facing_root = rig.get_node("%FacingRoot")
    aim_to_target_component.bind_facing_root(facing_root)

    process_mode = Node.PROCESS_MODE_INHERIT

func bind_level_container_ref(container: LevelContainer) -> void:
    level_container = container

    var fire: FireWeaponComponent = get_node("AttachmentsRig/%ComponentsRoot/FireWeaponComponent")
    fire.bind_projectile_system(level_container.get_node("%ProjectileSystem"))

func bind_target_provider(provider: TargetBaseProvider) -> void:
    aim_controller.bind_target_provider(provider)
