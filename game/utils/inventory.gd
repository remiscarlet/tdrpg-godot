class_name Inventory
extends Resource

var items: Dictionary[StringName, int] = { }
var capacity: int


func _init(new_capacity: int) -> void:
    capacity = new_capacity


func clear() -> void:
    items = { }


func is_empty() -> bool:
    return size() == 0


func is_full() -> bool:
    return size() == capacity


func size() -> int:
    var cardinality = 0
    for quantity in items.values():
        cardinality += quantity

    return cardinality


func list_item_ids() -> Array[StringName]:
    return items.keys()


func get_item_qty_or_default(item_name: StringName, default: int = 0) -> int:
    if item_name in items:
        return items[item_name]

    return default


func add_item(loot_name: StringName, quantity: int = 1) -> bool:
    if quantity == 0:
        return true
    elif quantity < 0:
        push_error("Tried adding negative items! (%s) (%s)" % [loot_name, quantity])
        return false
    elif size() >= capacity:
        print("Failed to add item to inventory - Inventory full!")
        return false

    if loot_name not in items:
        items[loot_name] = 0

    items[loot_name] += quantity

    return true


func remove_item(loot_name: StringName, quantity: int = 1) -> bool:
    if quantity == 0:
        return true
    elif quantity < 0:
        push_error("Tried removing negative items! (%s) (%s)" % [loot_name, quantity])
        return false
    elif loot_name not in items:
        print("Tried removing loot %s but did not exist in inventory!" % loot_name)
        return false
    elif items[loot_name] < quantity:
        print("Tried removing loot %s from inventory but did not have enough!" % loot_name)
        return false

    items[loot_name] -= quantity

    return true
