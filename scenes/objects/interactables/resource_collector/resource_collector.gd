extends InteractableBase
class_name ResourceCollector


func interact(interactor: Node2D) -> bool:
    var inventory: InventoryComponent = interactor.get_node("AttachmentsRoot/InventoryComponent")
    print(inventory.inventory)
    print(inventory.inventory.size())

    for entry in inventory.inventory.list_items():
        run_state.add_currency(entry.item.item_id, entry.quantity)
        inventory.inventory.remove_item(entry.item, entry.quantity)

    print(run_state.inventory)
    return true
