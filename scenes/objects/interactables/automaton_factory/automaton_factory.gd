extends InteractableBase
class_name AutomatonFactory

var combatant_system: CombatantSystem

func _enter_tree() -> void:
    super()
    # Interactables are scene tiles which get spawned in by Godot systems - not us. Thus, we can't dependency inject.
    # As a workaround, use groups that we'll query and wire up from somewhere we control such as LevelContainer's _ready()
    add_to_group(Groups.COMBATANT_SYSTEM_CONSUMERS)

func bind_combatant_system(system: CombatantSystem) -> void:
    combatant_system = system


func interact(interactor: Node2D) -> bool:
    var cost = 2

    if not run_state.has_item(Loot.CREDIT, cost):
        print("Failed to build Automaton - Not enough credits!")
        return false

    if not run_state.consume_item(Loot.CREDIT, cost):
        push_error("Failed to consume cost to build automaton!")
        return false

    var ctx = CombatantSpawnContext.new(global_position, CombatantTypes.DEFAULT_AUTOMATON)
    var combatant := await combatant_system.spawn(ctx) as DefaultAutomaton

    if combatant == null:
        push_error("Failed to spawn default automaton!")
        if not run_state.add_item(Loot.CREDIT, cost):
            push_error("Failed to refund cost of failed automaton build!")
        return false

    return true
