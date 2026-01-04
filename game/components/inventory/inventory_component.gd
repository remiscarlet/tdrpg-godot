extends Node2D
class_name InventoryComponent

signal loot_picked_up(loot: LootableBase)
signal inventory_full()
signal inventory_empty()

@export var capacity = 1

@export var pickupbox_path: NodePath
@onready var pickupbox: PickupboxComponent

var inventory: Inventory

## Public Methods

func bind_pickupbox_component(component: PickupboxComponent) -> void:
    print("Binding pickup box? %s" % component)
    pickupbox = component
    pickupbox.loot_encountered.connect(on_PickupboxComponent_loot_encountered)
    _try_activate()

func on_PickupboxComponent_loot_encountered(loot: LootableBase) -> void:
    print("INVENTORY PICKING UP LOOT: %s" % loot)

    if inventory.add_item(loot.loot_definition.item_id):
        loot.queue_free()
    else:
        print("Failed picking up loot %s!" % loot.loot_definition.item_id)

## Lifecycle methods

func _ready() -> void:
    inventory = Inventory.new(capacity)

    _try_activate()

func _enter_tree() -> void:
    set_physics_process(false)
    set_process(false)

## Helpers

func _try_activate() -> void:
    if pickupbox == null:
        return

    set_physics_process(true)
    set_process(true)
