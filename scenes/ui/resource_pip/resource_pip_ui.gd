extends HBoxContainer
class_name ResourcePipUI

var item_id: StringName
var quantity: int

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func configure(id: StringName, initial_quantity: int) -> void:
    item_id = id

    var def = DefinitionDB.get_item(item_id)
    texture_rect.texture = def.icon

    label.text = str(initial_quantity)

func update_quantity(new_quantity: int) -> void:
    label.text = str(new_quantity)
