class_name InventoryComponent
extends Node2D

## Purpose: Component that exposes inventory on an actor.
signal inventory_changed

@export var capacity = 1
@export var pickupbox_path: NodePath

var inventory: Inventory

@onready var pickupbox: PickupboxComponent


func _enter_tree() -> void:
    set_physics_process(false)
    set_process(false)


## Lifecycle methods
func _ready() -> void:
    _init_inventory()
    _try_activate()


## Public Methods
func configure(component: PickupboxComponent, inventory_capacity: int) -> void:
    _bind_pickupbox_component(component)
    capacity = inventory_capacity
    _init_inventory()


func on_PickupboxComponent_loot_encountered(loot: LootableBase) -> void:
    print("INVENTORY PICKING UP LOOT: %s" % loot)

    var item_id = loot.drop.loot_id
    if inventory.add_item(item_id):
        loot.queue_free()
        inventory_changed.emit()
    else:
        print("Failed picking up loot %s!" % item_id)


func transfer_loot_to_collector(run_state: RunState) -> bool:
    # TODO: These should really be transactional/have atomicity
    for item_id in inventory.list_item_ids():
        var qty = inventory.get_item_qty_or_default(item_id)

        run_state.add_currency(item_id, qty)
        inventory.remove_item(item_id, qty)

    inventory_changed.emit()

    return true


## Helpers
func _init_inventory() -> void:
    inventory = Inventory.new(capacity)


func _bind_pickupbox_component(component: PickupboxComponent) -> void:
    print("Binding pickup box? %s" % component)
    pickupbox = component
    pickupbox.loot_encountered.connect(on_PickupboxComponent_loot_encountered)
    _try_activate()


func _try_activate() -> void:
    if pickupbox == null:
        return

    set_physics_process(true)
    set_process(true)
