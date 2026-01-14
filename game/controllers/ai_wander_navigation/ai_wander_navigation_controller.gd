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
        body.desired_dir = Vector2.ZERO
        return

    var next_pos := agent.get_next_path_position()
    body.desired_dir = body.global_position.direction_to(next_pos)


func _setup() -> void:
    await get_tree().physics_frame
    agent.navigation_layers = navigation_layers
    _pick_new_target()

    timer.timeout.connect(_on_WanderTimer_timeout)


func _on_WanderTimer_timeout() -> void:
    _pick_new_target()


func _pick_new_target() -> void:
    var target := _get_some_random_reachable_point()
    agent.target_position = target
    timer.start(randf_range(wander_seconds_min, wander_seconds_max))


func _get_some_random_reachable_point() -> Vector2:
    var map_rid: RID = get_world_2d().get_navigation_map()

    var origin := NavigationServer2D.map_get_closest_point(map_rid, body.global_position)

    for i in range(wander_tries):
        # Random point in a disk around origin (uniform-ish).
        var angle := _rng.randf_range(0.0, TAU)
        var radius := sqrt(_rng.randf()) * wander_radius
        var candidate := origin + Vector2(radius, 0.0).rotated(angle)

        # Snap candidate onto the nav surface.
        candidate = NavigationServer2D.map_get_closest_point(map_rid, candidate)

        # Ask server for a path to prove it’s reachable.
        var path := (
            NavigationServer2D.map_get_path(
                map_rid,
                origin,
                candidate,
                true,
                navigation_layers, # optimize  # only regions in these nav layers
            )
        )

        if path.size() >= 2:
            # Use the *final* point in the returned path (it’s guaranteed to be on the nav surface).
            return path[path.size() - 1]

    # Fallback: don’t move.
    return origin
