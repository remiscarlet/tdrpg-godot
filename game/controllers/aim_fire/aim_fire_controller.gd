class_name AimFireController
extends Node2D

var last_dir = Vector2.ZERO

@onready var target_provider: TargetBaseProvider = MouseTargetProvider.new()
@onready var root: Node2D = get_parent().get_parent().get_parent() # Root/AttachmentsRoot/Controllers
@onready var aim_component: AimToTarget2DComponent
@onready var fire_component: FireWeaponComponent


static func wire_aim_fire_controller(actor: Node) -> void:
    # Kinda ugly that this helper is in here, but this is called from both CombatantBase and DefaultTurret
    var _rig = actor.get_node("AttachmentsRig")
    var _aim_component = _rig.get_node("%ComponentsRoot/AimToTarget2DComponent")
    var _fire_component = _rig.get_node("%ComponentsRoot/FireWeaponComponent")

    var aim_fire_controller = _rig.get_node("%ControllersRoot/AimFireController")
    aim_fire_controller.bind_aim_component(_aim_component)
    aim_fire_controller.bind_fire_component(_fire_component)


func _process(_delta: float) -> void:
    aim()


func bind_aim_component(component: AimToTarget2DComponent) -> void:
    aim_component = component


func bind_fire_component(component: FireWeaponComponent) -> void:
    fire_component = component


func bind_target_provider(provider: TargetBaseProvider) -> void:
    target_provider = provider


func aim() -> void:
    var target = _get_target()
    aim_component.set_target_angle(target.dir)


func try_fire(attack_type: StringName) -> bool:
    var target = _get_target()

    if not target.has_target:
        # Did not fire/no valid target
        return false

    return fire_component.fire(attack_type, target.dir)


func _get_target() -> AimingTargetResult:
    var dir = target_provider.get_target_direction(root)

    if dir == Vector2.ZERO:
        # No target - return the same dir as the last known target
        return AimingTargetResult.new(false, last_dir)

    last_dir = dir
    return AimingTargetResult.new(true, dir)
