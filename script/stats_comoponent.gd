#Si occupa di gestire i cambiamenti al mana/stamina e di passare i
#cambiamenti alla barra che la mostra a schermo

class_name StatsComponent

extends Node

const MAX_COOLDOWN: float = 5.0

signal energy_changed(new_value: float)

var parent: Player
var parent_stats: Stats
var powers: PowerUpData

var energy: float = 0.0
var cooldown: float = 0.0
var can_regen: bool = true

#region setup e _process
func setup(stats: Stats, pwrups: PowerUpData, player: Player)-> void:
	parent_stats = stats
	powers = pwrups
	parent = player
	energy = parent_stats.max_energy

func _process(delta: float) -> void:
	_handle_timers(delta)
	_regen_energy(parent_stats.regen_rate, delta)
	print("energia: ", energy)
#endregion

#region sottrazione energia
func _on_movement_component_energy_spended(action: String) -> void:
	var n: float = powers.power_ups[action]["cost"]
	energy = clampf(energy-n, 0.0, float(parent_stats.max_energy))
	emit_signal("energy_changed", energy)
	
	_add_cooldown(action)

func _add_cooldown(action: String) -> void:
	var t: float = powers.power_ups[action]["cooldown"]
	cooldown = clampf(cooldown+t, 0.0, MAX_COOLDOWN) 
#endregion

#region frame by frame func
func _handle_timers(delta: float) -> void:
	if cooldown > 0:
		can_regen = false
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0
			can_regen = true

func _regen_energy(rate: float, delta: float) -> void:
	if energy >= parent_stats.max_energy or !can_regen:
		return
	
	energy = clamp(energy+rate * delta, 0.0, parent_stats.max_energy) 
	emit_signal("energy_changed", energy)
#endregion

func get_energy() -> float: return energy
