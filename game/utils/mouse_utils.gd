class_name MouseUtils

## @brief Gets a normalized direction Vector2 to the mouse's global_position
##
## @param item The origin, represented by a CanvasItem inheriting object
static func get_dir_to_mouse(item: CanvasItem) -> Vector2:
	var from_pos: Vector2 = item.get_global_transform().origin
	var mouse_pos: Vector2 = item.get_global_mouse_position()
	return (mouse_pos - from_pos).normalized()