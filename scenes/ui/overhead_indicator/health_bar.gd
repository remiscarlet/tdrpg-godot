extends VBoxContainer
class_name HealthBarUI

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

func on_HealthComponent_health_changed(curr_health: float, max_health: float) -> void:
    progress_bar.max_value = max_health
    progress_bar.value = curr_health