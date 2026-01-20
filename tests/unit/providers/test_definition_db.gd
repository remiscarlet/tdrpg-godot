extends GdUnitTestSuite

const DefinitionDB = preload("res://game/providers/definition_db.gd")
const Loot = preload("res://game/utils/constants/loot.gd")
const CombatantTypes = preload("res://game/utils/constants/combatant_types.gd")


## Loads definitions from the default directories and verifies core tables are populated.
func test_loads_definitions_from_default_dirs() -> void:
    var db: DefinitionDB = auto_free(DefinitionDB.new())

    db._ready()

    assert_bool(db.items.is_empty()).is_false()
    assert_bool(db.turrets.is_empty()).is_false()
    assert_bool(db.enemies.is_empty()).is_false()
    assert_bool(db.players.is_empty()).is_false()
    assert_bool(db.ranged_attacks.is_empty()).is_false()


## Ensures lookups return the expected resource types and IDs for known entries.
func test_lookup_returns_expected_resources() -> void:
    var db: DefinitionDB = auto_free(DefinitionDB.new())
    db._ready()

    var scrap = db.get_item(Loot.SCRAP)
    assert_object(scrap).is_not_null()
    assert_str(scrap.id).is_equal("scrap")

    var default_enemy = db.get_enemy(CombatantTypes.DEFAULT_ENEMY)
    assert_object(default_enemy).is_not_null()
    assert_str(default_enemy.id).is_equal("default_enemy")

    var default_player = db.get_player(CombatantTypes.PLAYER)
    assert_object(default_player).is_not_null()
    assert_str(default_player.id).is_equal("player")

    var combatant = db.get_combatant(CombatantTypes.DEFAULT_ENEMY)
    assert_object(combatant).is_same(default_enemy)
