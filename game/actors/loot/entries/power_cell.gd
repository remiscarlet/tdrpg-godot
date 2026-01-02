extends LootDefinitionBase
class_name PowerCellItem

func _init() -> void:
	item_id = Loot.POWER_CELL
	scene = preload("res://scenes/objects/loot/power_cell/power_cell.tscn")