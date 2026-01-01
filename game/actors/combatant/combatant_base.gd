class_name CombatantBase
extends CharacterBody2D

var level_container: LevelContainer

var projectile_system: ProjectileSystem
var projectile_scene: PackedScene = preload(
	"res://scenes/projectiles/default_projectile/default_projectile.tscn"
)
var desired_dir: Vector2 = Vector2.ZERO

@export var move_speed: float = 200.0

@onready var hurtbox_collision_shape: CollisionShape2D = $"Hurtbox2DComponent/CollisionShape2D"
@onready var sprite_collision_shape: CollisionShape2D = $"BodyShape"

@onready var attachments_root: Node2D = $AttachmentsRoot
@onready var health: HealthComponent = attachments_root.get_node("HealthComponent")
@onready var bar: HealthBarView = attachments_root.get_node("HealthBarView")
@onready var player_ctrl: Node = attachments_root.get_node("Controllers/PlayerInputController")
@onready var ai_ctrl: Node2D = attachments_root.get_node("Controllers/AINavigationController")

func init(_projectile_system: ProjectileSystem) -> void:
	projectile_system = _projectile_system

func _ready() -> void:
	hurtbox_collision_shape.shape = sprite_collision_shape.shape
	health.health_changed.connect(_on_HealthComponent_health_changed)
	health.died.connect(_on_HealthComponent_died)

	set_controller(player_ctrl)

func _on_HealthComponent_health_changed(current: float, maximum: float) -> void:
	bar.set_ratio(current / maximum)
	bar.visible = current < maximum

func _on_HealthComponent_died(source: Node) -> void:
	print("%s killed by %s!" % [self, source])
	queue_free()

func set_controller_by_team_id(team_id: int) -> void:
	var active = player_ctrl if team_id == 0 else ai_ctrl
	print("ACTIVE: %s" % active)
	set_controller(active)

func set_controller(active: Node) -> void:
	# Disable both, enable one. Disabled means no _process/_physics_process/_input, etc. :contentReference[oaicite:3]{index=3}
	player_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
	ai_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
	active.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(_delta: float) -> void:
	# Controllers set desired_dir; motor applies it.
	velocity = desired_dir.normalized() * move_speed
	move_and_slide()

func set_level_container_ref(container: LevelContainer) -> void:
	print("Setting level container in CombatantBase: %s" % container)
	level_container = container
