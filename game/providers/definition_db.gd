extends Node

# Point these at your content folders
@export_dir var items_dir: String = "res://assets/definitions/items"
@export_dir var turrets_dir: String = "res://assets/definitions/turrets"
@export_dir var enemies_dir: String = "res://assets/definitions/enemies"
@export_dir var automatons_dir: String = "res://assets/definitions/automatons"
@export_dir var players_dir: String = "res://assets/definitions/players"
@export_dir var ranged_attacks_dir: String = "res://assets/definitions/ranged_attacks"

var items: Dictionary[StringName, ItemDefinition] = { }
var turrets: Dictionary[StringName, TurretDefinition] = { }
var enemies: Dictionary[StringName, EnemyDefinition] = { }
var automatons: Dictionary[StringName, AutomatonDefinition] = { }
var players: Dictionary[StringName, PlayerDefinition] = { }
var ranged_attacks: Dictionary[StringName, RangedAttackDefinition] = { }


func _ready() -> void:
    items = _load_items(items_dir)
    turrets = _load_turrets(turrets_dir)
    enemies = _load_enemies(enemies_dir)
    automatons = _load_automatons(automatons_dir)
    players = _load_players(players_dir)
    ranged_attacks = _load_ranged_attacks(ranged_attacks_dir)


func get_item(id: StringName) -> ItemDefinition:
    return items.get(id)


func get_turret(id: StringName) -> TurretDefinition:
    return turrets.get(id)


func get_enemy(id: StringName) -> EnemyDefinition:
    return enemies.get(id)


func get_automaton(id: StringName) -> AutomatonDefinition:
    return automatons.get(id)


func get_player(id: StringName) -> PlayerDefinition:
    return players.get(id)


func get_ranged_attack(id: StringName) -> RangedAttackDefinition:
    return ranged_attacks.get(id)


func get_combatant(id: StringName) -> CombatantDefinition:
    var enemy_def = get_enemy(id)
    if enemy_def:
        return enemy_def

    var automaton_def = get_automaton(id)
    if automaton_def:
        return automaton_def

    var player_def = get_player(id)
    if player_def:
        return player_def

    return null


func _load_dir(dir_path: String, expected_type: Variant) -> Dictionary[StringName, DefinitionBase]:
    var out: Dictionary[StringName, DefinitionBase] = { }

    var dir := DirAccess.open(dir_path)
    if dir == null:
        push_error("DefinitionDB: Failed to open dir: %s" % dir_path)
        return out

    dir.list_dir_begin()
    while true:
        var file_name := dir.get_next()
        if file_name == "":
            break
        if dir.current_is_dir():
            continue
        if not (file_name.ends_with(".tres") or file_name.ends_with(".res")):
            continue

        var path := dir_path.path_join(file_name)
        var res := load(path)
        if res == null:
            push_error("DefinitionDB: Failed to load: %s" % path)
            continue
        if not is_instance_of(res, expected_type):
            push_error("DefinitionDB: Wrong type at %s (%s)" % [path, res.get_class()])
            continue

        var def := res as DefinitionBase
        if def == null or def.id == &"":
            push_error("DefinitionDB: Missing id in %s" % path)
            continue

        out[def.id] = def

    dir.list_dir_end()
    return out


func _load_items(dir_path: String) -> Dictionary[StringName, ItemDefinition]:
    var base := _load_dir(dir_path, ItemDefinition)
    var out: Dictionary[StringName, ItemDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as ItemDefinition
    return out


func _load_turrets(dir_path: String) -> Dictionary[StringName, TurretDefinition]:
    var base := _load_dir(dir_path, TurretDefinition)
    var out: Dictionary[StringName, TurretDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as TurretDefinition
    return out


func _load_enemies(dir_path: String) -> Dictionary[StringName, EnemyDefinition]:
    var base := _load_dir(dir_path, EnemyDefinition)
    var out: Dictionary[StringName, EnemyDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as EnemyDefinition
    return out


func _load_automatons(dir_path: String) -> Dictionary[StringName, AutomatonDefinition]:
    var base := _load_dir(dir_path, AutomatonDefinition)
    var out: Dictionary[StringName, AutomatonDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as AutomatonDefinition
    return out


func _load_players(dir_path: String) -> Dictionary[StringName, PlayerDefinition]:
    var base := _load_dir(dir_path, PlayerDefinition)
    var out: Dictionary[StringName, PlayerDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as PlayerDefinition
    return out

func _load_ranged_attacks(dir_path: String) -> Dictionary[StringName, RangedAttackDefinition]:
    var base := _load_dir(dir_path, RangedAttackDefinition)
    var out: Dictionary[StringName, RangedAttackDefinition] = { }
    for id: StringName in base:
        out[id] = base[id] as RangedAttackDefinition
    return out