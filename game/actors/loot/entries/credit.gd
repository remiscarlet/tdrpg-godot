extends LootDefinitionBase
class_name CreditItem

func _init() -> void:
	item_id = Loot.CREDIT
	scene = preload("res://scenes/objects/loot/credit/credit.tscn")
