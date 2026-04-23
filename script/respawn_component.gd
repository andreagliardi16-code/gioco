# componente legata al player che memorizza l'ultima area di respawn attraversata
# attraverso la sua posizione o l'id, quando selezionato da editor

class_name RespawnComponent

extends Node

signal death_timer_finished

@export var respawn_area: StringName = &""

var respawn_position = null
var death_timer: Timer 

func handle_death() -> void:
	death_timer = Timer.new()
	death_timer.wait_time = 0.5
	death_timer.one_shot = true
	
	death_timer.timeout.connect(_on_timer_timeout)
	
	add_child(death_timer)
	death_timer.start()


func _on_timer_timeout() -> void:
	emit_signal("death_timer_finished")
	death_timer.queue_free()


func respawn() -> Vector2:
	if not (respawn_position == null):
		return respawn_position
	
	respawn_position = RespawnManager.get_spawn_point(respawn_area)
	return respawn_position
