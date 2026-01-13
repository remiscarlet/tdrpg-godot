extends CombatantBase
class_name DefaultAutomaton


func configure_combatant_post_ready(container: LevelContainer) -> void:
    var team_id = definition.team_id

    var _rig = get_node("AttachmentsRig")
    var sword_component: BasicSword = _rig.get_node("FacingRoot/Sensors/BasicSword")
    var target_sensor_component: TargetSensor2DComponent = _rig.get_node(
        "FacingRoot/Sensors/TargetSensor2DComponent"
    )
    var melee_attack_component: MeleeAttackComponent = _rig.get_node(
        "ComponentsRoot/MeleeAttackComponent"
    )

    melee_attack_component.bind_target_sensor_component(target_sensor_component)
    melee_attack_component.bind_sword(sword_component)
    target_sensor_component.set_team_id(team_id)

    PhysicsUtils.set_hitbox_collisions_for_team(sword_component, team_id)

    super(container)
