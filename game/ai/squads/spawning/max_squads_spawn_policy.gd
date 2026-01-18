class_name MaxSquadsSpawnPolicy
extends SquadSpawnPolicy

@export var max_squads_alive: int = 3
# For v1, policy also specifies the basic squad recipe.
@export var team_id: int = CombatantTeam.MUTANT
@export var squad_size: int = 4
@export var combatant_id: StringName = CombatantTypes.DEFAULT_ENEMY


func build_request(ctx: SquadSpawnPolicyContext) -> SquadSpawnRequest:
    if ctx == null or ctx.squad_system == null:
        return null

    var alive := ctx.squad_system.get_all_squads().size()
    if alive >= max_squads_alive:
        return null

    return SquadSpawnRequest.new(team_id, squad_size, combatant_id)
