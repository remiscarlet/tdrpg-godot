extends CombatantBase

@export var speed = 400
var screen_size: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_move(delta)

	if Input.is_action_pressed(Const.CONFIRM):
		_handle_fire()

func _handle_move(delta: float) -> void:
	var move_dir = Vector2.ZERO

	if Input.is_action_pressed(Const.MOVE_DOWN):
		move_dir.y += 1
	if Input.is_action_pressed(Const.MOVE_UP):
		move_dir.y -= 1
	if Input.is_action_pressed(Const.MOVE_LEFT):
		move_dir.x -= 1
	if Input.is_action_pressed(Const.MOVE_RIGHT):
		move_dir.x += 1

	if move_dir.length() > 0:
		velocity = move_dir.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()

	move_and_slide()

	position = position.clamp(Vector2.ZERO, screen_size)

# var last_fired: float = Time.get_unix_time_from_system()
var _last_fired: float = 0.0

func _can_fire(delay: float) -> bool:
	var now: float = Time.get_unix_time_from_system()
	return now >= _last_fired + delay

func _get_fire_delay() -> float:
	return 0.5

func _handle_fire() -> void:
	if not _can_fire(_get_fire_delay()):
		return

	var ctx := ProjectileSpawnContext.new(self, global_position)
	ctx.direction = MouseUtils.get_dir_to_mouse(self)

	projectile_system.spawn(projectile_scene, ctx)
