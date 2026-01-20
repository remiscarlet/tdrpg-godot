class_name HealthBarUI
extends VBoxContainer

## Purpose: Scene script for the overhead health bar UI.
@onready var progress_bar: TextureProgressBar = $TextureProgressBar


func on_HealthComponent_health_changed(curr_health: float, max_health: float) -> void:
    progress_bar.max_value = max_health
    progress_bar.value = curr_health
