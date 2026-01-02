extends Node2D
class_name InventoryComponent

signal loot_picked_up(loot: LootableBase)
signal inventory_full()
signal inventory_empty()

@export var capacity = 1

@export var pickupbox_path: NodePath
@onready var pickupbox: PickupboxComponent = get_node_or_null(pickupbox_path) as PickupboxComponent

var inventory: Inventory 

func _ready() -> void:
    inventory = Inventory.new(capacity)

    if pickupbox == null:
        pickupbox = $"../PickupboxComponent"
    pickupbox.loot_encountered.connect(on_PickupboxComponent_loot_encountered)

func on_PickupboxComponent_loot_encountered(loot: LootableBase) -> void:
    print("INVENTORY PICKING UP LOOT: %s" % loot)

    if inventory.add_item(loot.loot_definition.item_id):
        loot.queue_free()
    else:
        print("Failed picking up loot %s!" % loot.loot_definition.item_id)

