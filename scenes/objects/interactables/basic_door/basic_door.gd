extends InteractableBase
class_name BasicDoor

enum DoorState { CLOSED, OPEN, LOCKED }

@export var initial_state: DoorState = DoorState.CLOSED
@export var door_id: StringName

@onready var nav_link: NavigationLink2D = $NavigationLink2D
@onready var rig = $AttachmentsRig
@onready var solid_shape: CollisionShape2D = rig.get_node(
    "%FacingRoot/Sensors/StaticBody2D/CollisionShape2D"
)
@onready var sprite: AnimatedSprite2D = rig.get_node("%FacingRoot/Visuals/AnimatedSprite2D")
@onready var anim: AnimationPlayer

signal state_changed(state: DoorState)

var state: DoorState


func interact(_interactor: Node) -> bool:
    toggle()
    return true


func _ready() -> void:
    state = initial_state
    _apply_state_instant()


func open() -> void:
    if state == DoorState.OPEN or state == DoorState.LOCKED:
        return
    state = DoorState.OPEN
    print("OPEN")
    _apply_transition()


func close() -> void:
    if state != DoorState.OPEN:
        return
    state = DoorState.CLOSED
    print("CLOSING")
    _apply_transition()


func toggle() -> void:
    if state == DoorState.OPEN:
        close()
    else:
        open()


func _apply_state_instant() -> void:
    var is_open := state == DoorState.OPEN

    # Nav gate first: prevent new paths immediately when closing.
    if nav_link:
        nav_link.enabled = is_open

    # Collision: deferred is recommended by docs.
    if solid_shape:
        solid_shape.set_deferred("disabled", is_open)

    # Visuals
    if anim:
        anim.play("open" if is_open else "closed")
        anim.seek(anim.current_animation_length, true)
        anim.stop()
    elif sprite:
        sprite.play("open" if is_open else "closed")


func _apply_transition() -> void:
    var is_open := state == DoorState.OPEN

    if nav_link:
        nav_link.enabled = is_open

    if anim:
        anim.play("open" if is_open else "closed")
    else:
        # If you’re not animating, just apply immediately.
        if solid_shape:
            solid_shape.set_deferred("disabled", is_open)
        if sprite:
            sprite.play("open" if is_open else "closed")

    emit_signal("state_changed", state)


# Optional: call this from an AnimationPlayer track at the exact frame you want the door to become passable/solid.
func _set_passable(passable: bool) -> void:
    if solid_shape:
        solid_shape.set_deferred("disabled", passable)
