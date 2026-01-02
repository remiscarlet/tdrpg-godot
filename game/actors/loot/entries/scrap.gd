extends LootDefinitionBase
class_name ScrapItem

func _init() -> void:
	item_id = Loot.SCRAP
	scene = preload("res://scenes/objects/loot/scrap/scrap.tscn")