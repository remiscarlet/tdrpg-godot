class_name MeleeAttackComponent
extends Node2D

## Purpose: Component that performs melee attacks.
var target_sensor_component: TargetSensor2DComponent
var sword: BasicSword

@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
    _push_config()


func bind_sword(weapon: BasicSword) -> void:
    sword = weapon

    _push_config()


func bind_target_sensor_component(component: TargetSensor2DComponent) -> void:
    target_sensor_component = component

    _push_config()


func _push_config() -> void:
    if sword == null:
        return
    if target_sensor_component == null:
        return

    print("Readying MeleeAttackComponent")
    print(target_sensor_component)
    print(sword)
    target_sensor_component.set_target_sensor_radius(sword.swing_range)
    target_sensor_component.target_sensed.connect(sword.start_swing)
