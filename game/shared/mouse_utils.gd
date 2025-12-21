class_name MouseUtils

static func get_dir_to_mouse(item: CanvasItem) -> Vector2:
	var from_pos: Vector2 = item.get_global_transform().origin
	var mouse_pos: Vector2 = item.get_global_mouse_position()
	return (mouse_pos - from_pos).normalized()