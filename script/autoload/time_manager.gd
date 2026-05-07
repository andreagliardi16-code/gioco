# Questo nodo dovrebbe tenere traccia del timer globale, mandando un segnale
# al termine del tempo che resetta il gioco allo spawnpoint 

extends Node

@export var game_duration: int = 300  #secondi di gioco prima di morire e respawnare
var timer: float = game_duration
var is_running: bool = false

func _ready() -> void:
	_switch_timer(true)

func _process(delta: float) -> void:
	if not is_running:
		return
	
	timer -= delta
	if timer <= 0.0:
		end_timer()

func _switch_timer(arg: bool) -> void:
	is_running = arg

func end_timer():
	_switch_timer(false)
	timer = game_duration
	#fine partita e respawn
	pass

func get_time() -> float:
	return timer
