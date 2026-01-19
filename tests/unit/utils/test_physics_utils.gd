extends GdUnitTestSuite

const PhysicsUtils = preload("res://game/utils/physics_utils.gd")
const Layers = preload("res://game/utils/constants/layers.gd")
const CombatantTeam = preload("res://game/utils/enums/combatant_team.gd")


func test_as_mask_combines_layers() -> void:
    var mask := PhysicsUtils.as_mask(PackedInt32Array([1, 3]))
    assert_int(mask).is_equal(0b101)


func test_world_collidables_mask_matches_layer() -> void:
    var expected := PhysicsUtils.as_mask(PackedInt32Array([Layers.WORLD_SOLID]))
    assert_int(PhysicsUtils.get_world_collidables_mask()).is_equal(expected)


func test_player_projectile_layers_and_masks() -> void:
    var hit_layer_mask := 1 << (Layers.PLAYER_HITBOX - 1)
    var expected_mask := PhysicsUtils.as_mask(
        PackedInt32Array([Layers.ENEMY1_HURTBOX, Layers.ENEMY2_HURTBOX]),
    )

    assert_int(PhysicsUtils.get_projectile_layer(CombatantTeam.PLAYER)).is_equal(hit_layer_mask)
    assert_int(PhysicsUtils.get_projectile_mask(CombatantTeam.PLAYER)).is_equal(expected_mask)
