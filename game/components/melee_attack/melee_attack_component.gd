class_name MeleeAttackComponent
extends Node2D

var target_sensor_component: TargetSensor2DComponent
var sword: BasicSword

@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
    print("Readying MeleeAttackComponent")
    print(target_sensor_component)
    print(sword)
    target_sensor_component.set_sensor_radius(sword.swing_range)
    target_sensor_component.target_sensed.connect(sword.start_swing)
    # attack_timer.timeout.connect(target_sensor_component)


func bind_sword(weapon: BasicSword) -> void:
    sword = weapon


func bind_target_sensor_component(component: TargetSensor2DComponent) -> void:
    target_sensor_component = component
