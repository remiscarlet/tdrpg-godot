extends LootEntryBase
class_name CreditItem

func _init() -> void:
	item_id = Loot.CREDIT
	qty_min = 1
	qty_max = 1
	scene = preload("res://scenes/objects/loot/credit/credit.tscn")
