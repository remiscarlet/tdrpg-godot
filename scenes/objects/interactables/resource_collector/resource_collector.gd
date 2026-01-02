extends InteractableBase
class_name ResourceCollector

func _enter_tree() -> void:
    super()
    # Interactables are scene tiles which get spawned in by Godot systems - not us. Thus, we can't dependency inject.
    # As a workaround, use groups that we'll query and wire up from somewhere we control such as LevelContainer's _ready()
    add_to_group(Groups.COLLECTORS)

func interact(interactor: Node2D) -> bool:
    var inventory: InventoryComponent = interactor.get_node("AttachmentsRoot/InventoryComponent")
    print(inventory.inventory)
    print(inventory.inventory.size())

    for item_id in inventory.inventory.list_item_ids():
        var qty = inventory.inventory.get_item_qty_or_default(item_id)

        run_state.add_currency(item_id, qty)
        inventory.inventory.remove_item(item_id, qty)

    print(run_state.inventory)
    return true
