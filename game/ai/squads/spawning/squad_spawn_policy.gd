class_name SquadSpawnPolicy
extends Resource
## Policy produces a spawn request (or null) given the current world state.
## It should NOT instantiate scenes or pick exact positions.


func build_request(_ctx: SquadSpawnPolicyContext) -> SquadSpawnRequest:
    return null
