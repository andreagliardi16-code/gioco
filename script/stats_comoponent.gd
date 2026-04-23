#Si occupa di gestire i cambiamenti al mana/stamina e di passare i
#cambiamenti alla barra che la mostra a schermo

class_name StatsComponent

extends Node

const MAX_COOLDOWN: float = 5.0
const MAX_REGEN_TIMER: float = 3.5

signal energy_changed(new_value: float)

var parent: Player = null
var parent_stats: Stats = null
var powers: PowerUpData = null

@export var regen_curve: Curve = null

var energy: float = 0.0
var cooldown: float = 0.0
var regen_accel_timer: float = 0.0
var can_regen: bool = true
var regen_is_accelerating: bool = false

#region setup e _process
func setup(stats: Stats, pwrups: PowerUpData, player: Player)-> void:
	parent_stats = stats
	powers = pwrups
	parent = player
	energy = parent_stats.max_energy

func _process(delta: float) -> void:
	_handle_timers(delta)
	_regen_energy(parent_stats.regen_rate, delta)
#endregion

#region sottrazione energia
func _on_movement_component_energy_spended(action: String) -> void:
	var n: float = powers.power_ups[action]["cost"]
	energy = clampf(energy-n, 0.0, float(parent_stats.max_energy))
	emit_signal("energy_changed", energy)
	
	_add_cooldown(action)
	_end_regen()

func _add_cooldown(action: String) -> void:
	var t: float = powers.power_ups[action]["cooldown"]
	cooldown = clampf(cooldown+t, 0.0, MAX_COOLDOWN) 
#endregion

#region frame by frame func
func _handle_timers(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta
		if cooldown <= 0:
			cooldown = 0
			_start_regen()
	if regen_is_accelerating:
		regen_accel_timer += delta
		if regen_accel_timer >= MAX_REGEN_TIMER:
			regen_is_accelerating = false

func _regen_energy(rate: float, delta: float) -> void:
	if energy >= parent_stats.max_energy or !can_regen:
		return
	
	rate = _get_regen(rate, delta)
	energy = clamp(energy+rate * delta, 0.0, parent_stats.max_energy) 
	emit_signal("energy_changed", energy)

func _get_regen(rate: float, delta: float) -> float:
	if not regen_is_accelerating:
		return rate
	
	var n: float = clampf(regen_accel_timer / MAX_REGEN_TIMER, 0.0, 1.0)
	var x: float = regen_curve.sample(n)*rate
	return x
#endregion

#region start e end regen
func _start_regen() -> void:
	can_regen = true
	regen_accel_timer = 0.0
	regen_is_accelerating = true

func _end_regen() -> void:
	can_regen = false
	regen_is_accelerating = false
#endregion

func get_energy() -> float: return energy
