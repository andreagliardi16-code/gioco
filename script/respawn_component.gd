# componente legata al player che memorizza l'ultima area di respawn attraversata
# attraverso la sua posizione o l'id, quando selezionato da editor

class_name RespawnComponent

extends Node


const ERR_VECTOR: Vector2 = Vector2(-1, -1)


signal death_timer_finished


var respawn_area: StringName = &""
var respawn_position : Vector2 = ERR_VECTOR
var death_timer: Timer 


func respawn() -> Vector2:
	if not (respawn_position == ERR_VECTOR):
		print(respawn_position)
		return respawn_position
	
	respawn_position = RespawnManager.get_spawn_point(respawn_area)
	return respawn_position


func update_pos(id: StringName, pos: Vector2 = ERR_VECTOR) -> void:
	if not id == &"":
		respawn_area = id
	
	if not pos == ERR_VECTOR:
		respawn_position = pos
