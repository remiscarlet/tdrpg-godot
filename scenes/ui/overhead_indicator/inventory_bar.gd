extends HBoxContainer
class_name InventoryBarUI

var inventory_component: InventoryComponent
var resource_pip_scene: PackedScene = preload("res://scenes/ui/resource_pip/resource_pip_ui.tscn")
var _pips: Dictionary[StringName, ResourcePipUI] = {}

func bind_inventory_component(component: InventoryComponent) -> void:
    inventory_component = component

func on_InventoryComponent_inventory_changed() -> void:
    var unseen: Dictionary[StringName, bool] = {}

    var inv = inventory_component.inventory

    for item_id in _pips.keys():
        unseen[item_id] = true

    for item_id in inv.list_item_ids():
        var quantity = inv.get_item_qty_or_default(item_id)

        if quantity == 0:
            # Treat zero-quantity as not existing
            continue

        if item_id in unseen:
            unseen[item_id] = false

        if item_id not in _pips:
            var pip = resource_pip_scene.instantiate()

            add_child(pip)
            pip.configure(item_id, quantity)

            _pips.set(item_id, pip)
        else:
            var pip = _pips[item_id]
            pip.update_quantity(quantity)

    for item_id in unseen:
        if unseen[item_id]:
            _pips[item_id].queue_free()
            _pips.erase(item_id)
