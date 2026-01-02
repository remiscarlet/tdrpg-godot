class_name CombatantBase
extends CharacterBody2D

var level_container: LevelContainer

var desired_dir: Vector2 = Vector2.ZERO

@export var move_speed: float = 200.0

@onready var hurtbox_collision_shape: CollisionShape2D = $"Hurtbox2DComponent/CollisionShape2D"
@onready var sprite_collision_shape: CollisionShape2D = $"BodyShape"

@onready var attachments_root: Node2D = $AttachmentsRoot
@onready var health: HealthComponent = attachments_root.get_node("HealthComponent")
@onready var bar: HealthBarView = attachments_root.get_node("HealthBarView")
@onready var player_ctrl: Node = attachments_root.get_node("Controllers/PlayerInputController")
@onready var ai_hauler_ctrl: Node = attachments_root.get_node("Controllers/AIHaulerController")
@onready var ai_wander_ctrl: Node2D = attachments_root.get_node("Controllers/AIWanderNavigationController")

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
    var active
    if team_id != CombatantTeam.PLAYER:
        active = ai_wander_ctrl
    elif (self as Player) == null:
        active = ai_hauler_ctrl
    else:
        active = player_ctrl

    set_controller(active)

func set_controller(active: Node) -> void:
    print("Activating %s on %s" % [active, self])
    # Disable both, enable one. Disabled means no _process/_physics_process/_input, etc. :contentReference[oaicite:3]{index=3}
    player_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_hauler_ctrl.process_mode = Node.PROCESS_MODE_DISABLED
    ai_wander_ctrl.process_mode = Node.PROCESS_MODE_DISABLED

    active.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(_delta: float) -> void:
    # Controllers set desired_dir; motor applies it.
    velocity = desired_dir.normalized() * move_speed
    move_and_slide()

func set_level_container_ref(container: LevelContainer) -> void:
    level_container = container

    var fire: FireWeaponComponent = $"AttachmentsRoot/FireWeaponComponent"
    fire.set_projectile_system(level_container.get_node("%ProjectileSystem"))

    var loot: LootableComponent = $"AttachmentsRoot/LootableComponent"
    loot.set_loot_system(level_container.get_node("%LootSystem"))

    var ai_hauler_controller: AIHaulerController = $"AttachmentsRoot/Controllers/AIHaulerController"
    ai_hauler_controller.set_hauler_task_system(level_container.get_node("%HaulerTaskSystem"))
