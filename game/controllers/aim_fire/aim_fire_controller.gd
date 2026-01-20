class_name AimFireController
extends Node2D

## Purpose: Controller for aiming and firing weapons.
var last_dir = Vector2.ZERO
var target_provider: TargetBaseProvider
var aim_component: AimToTarget2DComponent
var fire_component: FireWeaponComponent

@onready var root: Node2D = get_parent().get_parent().get_parent() # Root/AttachmentsRoot/Controllers


func _enter_tree() -> void:
    set_process(false)
    set_physics_process(false)


func _ready() -> void:
    _activate_if_ready()


func _process(_delta: float) -> void:
    aim()


func bind_aim_to_target_component(component: AimToTarget2DComponent) -> void:
    aim_component = component

    _activate_if_ready()


func bind_fire_weapon_component(component: FireWeaponComponent) -> void:
    fire_component = component

    _activate_if_ready()


func bind_target_provider(provider: TargetBaseProvider) -> void:
    target_provider = provider

    _activate_if_ready()


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


func _activate_if_ready() -> void:
    if aim_component == null:
        return
    if fire_component == null:
        return
    if target_provider == null:
        return

    set_process(true)
    set_physics_process(true)
