extends GdUnitTestSuite

const FiniteStateMachine = preload("res://game/fsm/finite_state_machine.gd")
const FSMState = preload("res://game/fsm/fsm_state.gd")


class TestState extends FSMState:
    var name: String
    var enters := 0
    var exits := 0
    var updates := 0
    var physics_updates := 0
    var events: Array = []
    var on_update: Callable = func(_ctx, _dt): pass


    func _init(n: String, update_fn: Callable = Callable()) -> void:
        name = n
        if update_fn != Callable():
            on_update = update_fn


    func enter(_ctx: Dictionary) -> void:
        enters += 1


    func exit(_ctx: Dictionary) -> void:
        exits += 1


    func update(ctx: Dictionary, dt: float) -> void:
        updates += 1
        on_update.call(ctx, dt)


    func physics_update(ctx: Dictionary, dt: float) -> void:
        physics_updates += 1
        on_update.call(ctx, dt)


    func handle_event(_ctx: Dictionary, event: StringName, data: Variant) -> void:
        events.append([event, data])


func test_init_and_step_sets_initial_state() -> void:
    var fsm: FiniteStateMachine = auto_free(FiniteStateMachine.new())
    var ctx: Dictionary = {}
    var initial: TestState = TestState.new("A")

    fsm.init(ctx, initial)
    fsm.step(0.1)

    assert_object(fsm._state).is_same(initial)
    assert_int(initial.enters).is_equal(1)
    assert_int(initial.updates).is_equal(1)


func test_switch_during_update_applies_after_update() -> void:
    var fsm: FiniteStateMachine = auto_free(FiniteStateMachine.new())
    var ctx: Dictionary = {"fsm": fsm}
    var state_b: TestState = TestState.new("B")
    var state_a: TestState = TestState.new("A", func(local_ctx, _dt):
        local_ctx["fsm"].switch_to(state_b, &"to_b")
    )

    fsm.init(ctx, state_a)
    fsm.step(0.1)

    assert_object(fsm._state).is_same(state_b)
    assert_int(state_a.enters).is_equal(1)
    assert_int(state_a.exits).is_equal(1)
    assert_int(state_b.enters).is_equal(1)
    assert_int(state_b.updates).is_equal(0) # update happens on next step


func test_emit_event_forwards_to_active_state() -> void:
    var fsm: FiniteStateMachine = auto_free(FiniteStateMachine.new())
    var ctx: Dictionary = {}
    var state: TestState = TestState.new("A")

    fsm.init(ctx, state)
    fsm.step(0.1)

    fsm.emit_event(&"ping", 123)

    assert_array(state.events).has_size(1)
    assert_array(state.events[0]).is_equal([&"ping", 123])
