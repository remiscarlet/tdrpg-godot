extends Control
class_name ResourcePipUI

var item_id: StringName
var quantity: int

@onready var texture_rect: TextureRect = %TextureRect
@onready var label: Label = %Label

var temp_credits_texture: Texture2D = preload("res://assets/art/credit.png")

func configure(id: StringName, initial_quantity: int) -> void:
    item_id = id
    texture_rect.texture = temp_credits_texture

    label.text = str(initial_quantity)

func update_quantity(new_quantity: int) -> void:
    label.text = str(new_quantity)
