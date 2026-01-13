class_name MiscUtils


static func dump_ps(tag: String, ps: PackedScene) -> void:
    print(
        (
            "%s: path='%s' can_instantiate=%s state=%s"
            % [tag, ps.resource_path, ps.can_instantiate(), ps.get_state()]
        ),
    )
