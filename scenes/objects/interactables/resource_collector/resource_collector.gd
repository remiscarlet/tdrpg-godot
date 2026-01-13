extends InteractableBase
class_name ResourceCollector


func _enter_tree() -> void:
    super()
    # Interactables are scene tiles which get spawned in by Godot systems - not us. Thus, we can't dependency inject.
    # As a workaround, use groups that we'll query and wire up from somewhere we control such as LevelContainer's _ready()
    add_to_group(Groups.COLLECTORS)


func interact(interactor: Node2D) -> bool:
    var inventory: InventoryComponent = interactor.get_node(
        "AttachmentsRig/ComponentsRoot/InventoryComponent"
    )
    return inventory.transfer_loot_to_collector(run_state)
