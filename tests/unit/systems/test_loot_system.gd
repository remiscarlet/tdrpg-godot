extends GdUnitTestSuite

const LootSystem = preload("res://game/systems/loot_system.gd")
const LootDrop = preload("res://game/actors/loot/loot_drop.gd")
const LootableBase = preload("res://game/actors/loot/lootable_base.gd")
const Groups = preload("res://game/utils/constants/groups.gd")

func _make_stub_scene() -> PackedScene:
    return load("res://game/actors/loot/lootable_base.tscn")


## Spawns loot and asserts the lootable node is created, parented, and flagged correctly.
func test_spawn_instantiates_and_parents_lootable() -> void:
    var loot_container := Node2D.new()
    loot_container.name = "LootContainer"
    add_child(loot_container)

    var system: LootSystem = LootSystem.new()
    system.loot_container = loot_container
    system.lootable_base_scene = _make_stub_scene()

    var loot := LootDrop.new(Loot.SCRAP, 1)
    var spawned: LootableBase = await system.spawn(loot, Vector2(5, 0), Vector2.RIGHT)

    assert_object(spawned).is_not_null()
    assert_object(spawned.drop).is_not_null()
    assert_object(spawned.get_parent()).is_same(loot_container)
    assert_bool(spawned.is_in_group(Groups.LOOT)).is_true()

    spawned.queue_free()
    loot_container.queue_free()
    await get_tree().process_frame()
