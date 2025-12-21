extends Area2D

@export var speed = 400
var screen_size: Vector2

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload("res://scenes/projectiles/default_projectile/default_projectile.tscn")

func init(projectile_system_: ProjectileSystem) -> void:
	projectile_system = projectile_system_

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_move(delta)

	if Input.is_action_pressed(Const.CONFIRM):
		_handle_fire()

func _handle_move(delta: float) -> void:
	var velocity = Vector2.ZERO

	if Input.is_action_pressed(Const.MOVE_DOWN):
		velocity.y += 1
	if Input.is_action_pressed(Const.MOVE_UP):
		velocity.y -= 1
	if Input.is_action_pressed(Const.MOVE_LEFT):
		velocity.x -= 1
	if Input.is_action_pressed(Const.MOVE_RIGHT):
		velocity.x += 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

# var last_fired: float = Time.get_unix_time_from_system()
var _last_fired: float = 0.0

func _can_fire(delay: float) -> bool:
	var now: float = Time.get_unix_time_from_system()
	return now >= _last_fired + delay

func _handle_fire() -> void:
	if not _can_fire(0.1):
		return

	var ctx := ProjectileSpawnContext.new(global_position)
	ctx.direction = MouseUtils.get_dir_to_mouse(self)

	projectile_system.spawn(projectile_scene, ctx)
