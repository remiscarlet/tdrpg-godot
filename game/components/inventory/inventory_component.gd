extends Node2D
class_name InventoryComponent

signal loot_picked_up(loot: LootableBase)
signal inventory_full()
signal inventory_empty()

@export var capacity = 1

@export var pickupbox_path: NodePath
@onready var pickupbox: PickupboxComponent = get_node_or_null(pickupbox_path) as PickupboxComponent

var inventory := Inventory.new(capacity)

class InventoryEntry:
    var item: LootDefinitionBase
    var quantity: int

    func _init(loot_item: LootDefinitionBase, loot_quantity: int) -> void:
        item = loot_item
        quantity = loot_quantity

    func add(delta: int) -> void:
        self.quantity += delta

    func remove(delta: int) -> void:
        self.quantity -= delta

class Inventory:
    var items: Dictionary[StringName, InventoryEntry] = {}
    var capacity: int

    func _init(new_capacity: int) -> void:
        capacity = new_capacity

    func size() -> int:
        var cardinality = 0
        for item_id in self.items:
            var item = self.items[item_id]
            cardinality += item.quantity

        return cardinality

    func list_items() -> Array[InventoryEntry]:
        return self.items.values()

    func add_item(loot: LootDefinitionBase, quantity: int = 1) -> bool:
        if self.size() >= self.capacity:
            print("Failed to add item to inventory - Inventory full!")
            return false

        if loot.item_id not in self.items:
            self.items[loot.item_id] = InventoryEntry.new(loot, 0)

        self.items[loot.item_id].add(quantity)

        return true

    func remove_item(loot: LootDefinitionBase, quantity: int = 1) -> bool:
        if loot.item_id not in self.items:
            print("Tried removing loot %s but did not exist in inventory!" % loot.item_id)
            return false

        if self.items[loot.item_id].quantity < quantity:
            print("Tried removing loot %s from inventory but did not have enough!" % loot.item_id)
            return false

        self.items[loot.item_id].remove(quantity)

        return true


func _ready() -> void:
    if pickupbox == null:
        pickupbox = $"../PickupboxComponent"
    pickupbox.loot_encountered.connect(on_PickupboxComponent_loot_encountered)

func on_PickupboxComponent_loot_encountered(loot: LootableBase) -> void:
    print("INVENTORY PICKING UP LOOT: %s" % loot)

    if inventory.add_item(loot.loot_definition):
        loot.queue_free()
    else:
        print("Failed picking up loot %s!" % loot.loot_definition.item_id)

