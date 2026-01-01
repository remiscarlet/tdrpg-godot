extends LootEntryBase
class_name PowerCellItem

func _init() -> void:
	item_id = Loot.POWER_CELL
	qty_min = 1
	qty_max = 1
	scene = preload("res://scenes/objects/loot/power_cell/power_cell.tscn")