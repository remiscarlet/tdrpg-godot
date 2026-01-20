extends GdUnitTestSuite
## Purpose: Validates inventory capacity and add/remove behaviors.

# Testee: res://game/utils/inventory.gd
# Scope: unit
# Tags: inventory
const Inventory = preload("res://game/utils/inventory.gd")
const IRON := StringName("iron")
const COPPER := StringName("copper")
const GOLD := StringName("gold")
const UNKNOWN := StringName("unknown")

var inventory: Inventory


func before_test() -> void:
    inventory = Inventory.new(2)


## Verifies a new inventory reports empty state and capacity flags correctly.
func test_empty_inventory_has_zero_size() -> void:
    assert_int(inventory.size()).is_equal(0)
    assert_bool(inventory.is_empty()).is_true()
    assert_bool(inventory.is_full()).is_false()


## Confirms adding items within capacity succeeds and updates counts/full flag.
func test_add_item_within_capacity_succeeds() -> void:
    assert_bool(inventory.add_item(IRON, 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(IRON)).is_equal(1)
    assert_int(inventory.size()).is_equal(1)
    assert_bool(inventory.is_full()).is_false()

    assert_bool(inventory.add_item(IRON, 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(IRON)).is_equal(2)
    assert_bool(inventory.is_full()).is_true()


## Ensures adding beyond capacity fails without altering stored items.
func test_add_item_fails_when_capacity_reached() -> void:
    inventory.add_item(IRON, 1)
    inventory.add_item(COPPER, 1)

    var result := inventory.add_item(GOLD, 1)
    assert_bool(result).is_false()
    assert_int(inventory.size()).is_equal(2)
    assert_bool(inventory.is_full()).is_true()


## Rejects negative quantity additions and leaves inventory unchanged.
func test_add_item_rejects_negative_quantity() -> void:
    var result := inventory.add_item(IRON, -1)
    assert_bool(result).is_false()
    assert_int(inventory.size()).is_equal(0)


## Allows zero-quantity additions as no-ops without modifying size.
func test_add_item_allows_zero_quantity_noop() -> void:
    var result := inventory.add_item(IRON, 0)
    assert_bool(result).is_true()
    assert_int(inventory.size()).is_equal(0)


## Covers success and failure removal paths and resulting quantities.
func test_remove_item_success_and_failure_paths() -> void:
    inventory.add_item(IRON, 2)

    assert_bool(inventory.remove_item(IRON, 1)).is_true()
    assert_int(inventory.get_item_qty_or_default(IRON)).is_equal(1)

    assert_bool(inventory.remove_item(IRON, 2)).is_false()
    assert_int(inventory.get_item_qty_or_default(IRON)).is_equal(1)

    assert_bool(inventory.remove_item(UNKNOWN, 1)).is_false()


## Ensures negative removal requests are rejected and do not alter inventory.
func test_remove_item_negative_rejected() -> void:
    var result := inventory.remove_item(IRON, -1)
    assert_bool(result).is_false()
