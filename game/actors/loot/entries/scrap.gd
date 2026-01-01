extends LootEntryBase
class_name ScrapItem

func _init() -> void:
	item_id = Loot.SCRAP
	qty_min = 1
	qty_max = 1
	scene = preload("res://scenes/objects/loot/scrap/scrap.tscn")