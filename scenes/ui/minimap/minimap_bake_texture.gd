extends TextureRect
class_name MinimapBaseMap


func _ready() -> void:
    expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
