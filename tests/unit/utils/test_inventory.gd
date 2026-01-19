extends GdUnitTestSuite

const Inventory = preload("res://game/utils/inventory.gd")

var inventory: Inventory


func before_test() -> void:
    inventory = Inventory.new(2)


func test_empty_inventory_has_zero_size() -> void:
    assert_int(inventory.size()).is_equal(0)
    assert_bool(inventory.is_empty()).is_true()
    assert_bool(inventory.is_full()).is_false()


func test_add_item_within_capacity_succeeds() -> void:
    assert_bool(inventory.add_item(&"iron", 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(&"iron")).is_equal(1)
    assert_int(inventory.size()).is_equal(1)
    assert_bool(inventory.is_full()).is_false()

    assert_bool(inventory.add_item(&"iron", 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(&"iron")).is_equal(2)
    assert_bool(inventory.is_full()).is_true()


func test_add_item_fails_when_capacity_reached() -> void:
    inventory.add_item(&"iron", 1)
    inventory.add_item(&"copper", 1)

    var result := inventory.add_item(&"gold", 1)
    assert_bool(result).is_false()
    assert_int(inventory.size()).is_equal(2)
    assert_bool(inventory.is_full()).is_true()


func test_add_item_rejects_negative_quantity() -> void:
    var result := inventory.add_item(&"iron", -1)
    assert_bool(result).is_false()
    assert_int(inventory.size()).is_equal(0)


func test_add_item_allows_zero_quantity_noop() -> void:
    var result := inventory.add_item(&"iron", 0)
    assert_bool(result).is_true()
    assert_int(inventory.size()).is_equal(0)


func test_remove_item_success_and_failure_paths() -> void:
    inventory.add_item(&"iron", 2)

    assert_bool(inventory.remove_item(&"iron", 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(&"iron")).is_equal(1)

    assert_bool(inventory.remove_item(&"iron", 2)).is_false()
    assert_int(inventory.get_item_qty_or_default(&"iron")).is_equal(1)

    assert_bool(inventory.remove_item(&"unknown", 1)).is_false()


func test_remove_item_negative_rejected() -> void:
    var result := inventory.remove_item(&"iron", -1)
    assert_bool(result).is_false()
