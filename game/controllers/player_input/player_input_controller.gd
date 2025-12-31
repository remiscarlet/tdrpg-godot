extends Node

@onready var body: CombatantBase = get_parent().get_parent()

func _physics_process(_delta: float) -> void:
	var d := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	body.desired_dir = d.normalized()