extends Node2D
class_name TargetSensor2DComponent

@export var target_group: StringName = &"targetable"
@export var area: Area2D

var _candidates: Array[Node2D] = []

func _ready() -> void:
	if area == null:
		# Common convention: child named "TargetSensorArea"
		area = get_node_or_null("TargetSensorArea") as Area2D
		assert(area != null, "TargetSensor2DComponent needs an Area2D reference.")

	area.monitoring = true
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)

func get_candidates() -> Array[Node2D]:
	_prune_invalid()
	return _candidates

func _on_area_entered(body: Node) -> void:
	var node2d := body as Node2D
	if node2d == null:
		return
	# if target_group != &"" and not node2d.is_in_group(target_group):
	# 	return
	_candidates.append(node2d)

func _on_area_exited(body: Node) -> void:
	var node2d := body as Node2D
	if node2d == null:
		return
	_candidates.erase(node2d)

func _prune_invalid() -> void:
	for i in range(_candidates.size() - 1, -1, -1):
		if not is_instance_valid(_candidates[i]):
			_candidates.remove_at(i)