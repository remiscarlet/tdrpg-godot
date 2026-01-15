class_name DefinitionBase
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export_color_no_alpha var minimap_icon_color: Color
@export var minimap_icon_scene: PackedScene
@export var tags: Array[StringName] = []
@export var scene: PackedScene