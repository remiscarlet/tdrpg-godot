class_name LootContext
extends RefCounted

var tags: PackedStringArray = PackedStringArray()
var level: int = 1


func _init(_tags: PackedStringArray = PackedStringArray(), _level: int = 1) -> void:
    tags = _tags
    level = _level


func has_tag(tag: String) -> bool:
    return tags.has(tag)
