# nodo che controlla l'aggiornamento della barra dell'energia
# del player

class_name Hud

extends CanvasLayer

var parent_data: PlayerStats = null
var parent_stats: StatsComponent = null

@onready var energy_bar = $PlayerControl/ProgressBar

#region setup
func setup(data: PlayerStats, stats: StatsComponent) -> void:
	parent_data = data
	parent_stats = stats

func create_bar() -> void:
	if not energy_bar: return
	energy_bar.max_value = parent_data.max_energy
	energy_bar.value = energy_bar.max_value
#endregion

#region segnali
func _on_character_body_2d_components_linked() -> void:
	create_bar()

func _on_stats_component_energy_changed(new_value: float) -> void:
	energy_bar.value = new_value
#endregion
