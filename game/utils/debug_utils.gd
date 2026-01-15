class_name DebugUtils


static func dump_ps(tag: String, ps: PackedScene) -> void:
    print(
        (
            "%s: path='%s' can_instantiate=%s state=%s"
            % [tag, ps.resource_path, ps.can_instantiate(), ps.get_state()]
        ),
    )


static func object_props_to_dict(o: Object) -> Dictionary:
    var d := { }
    for info in o.get_property_list():
        var name := String(info.get("name", ""))
        if name.is_empty():
            continue
        d[name] = o.get(name)
    return d


static func pretty_object(o: Object) -> String:
    return JSON.stringify(object_props_to_dict(o), "  ")
