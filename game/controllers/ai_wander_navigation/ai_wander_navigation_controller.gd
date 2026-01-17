class_name AIWanderNavigationController
extends Node2D

@export var wander_radius := 400.0
@export var wander_tries := 12
@export_flags_2d_navigation var navigation_layers := 1 # must match region layers you want to use
@export var wander_seconds_min := 1.0
@export var wander_seconds_max := 2.5

var _rng := RandomNumberGenerator.new()

@onready var body: CombatantBase = get_parent().get_parent().get_parent() # CombatantBase/AttachmentsRoot/Controllers
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $WanderTimer


func _ready() -> void:
    _rng.randomize()

    # Avoid querying paths in _ready() before navigation map sync
    _setup.call_deferred()


func _physics_process(_delta: float) -> void:
    if agent.is_navigation_finished():
        body.set_desired_move(Vector2.ZERO)
        return

    var next_pos := agent.get_next_path_position()
    body.set_desired_move(body.global_position.direction_to(next_pos))


func _setup() -> void:
    await get_tree().physics_frame
    agent.navigation_layers = navigation_layers
    _pick_new_target()

    timer.timeout.connect(_on_WanderTimer_timeout)


func _on_WanderTimer_timeout() -> void:
    _pick_new_target()


func _pick_new_target() -> void:
    var nav_rid := get_world_2d().get_navigation_map()
    var target := NavUtils.get_some_random_reachable_point(nav_rid, body.global_position, wander_tries, wander_radius)

    agent.target_position = target
    timer.start(randf_range(wander_seconds_min, wander_seconds_max))
