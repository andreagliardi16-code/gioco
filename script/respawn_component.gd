# componente legata al player che memorizza l'ultima area di respawn attraversata
# attraverso la sua posizione o l'id, quando selezionato da editor

class_name RespawnComponent

extends Node

signal death_timer_finished

@export var respawn_area: StringName = &""

var respawn_position = null
var death_timer: Timer 


func respawn() -> Vector2:
	if not (respawn_position == null):
		return respawn_position
	
	respawn_position = RespawnManager.get_spawn_point(respawn_area)
	return respawn_position


func update_pos(pos: Vector2, id: StringName) -> void:
	if not id == &"":
		respawn_area = id
	
	respawn_position = pos
