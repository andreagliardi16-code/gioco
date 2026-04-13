# componente legata al player che memorizza l'ultima area di respawn attraversata
# attraverso la sua posizione o l'id, quando selezionato da editor

class_name RespawnComponent

extends Node

@export var respawn_area: StringName = &""

var respawn_position = null

func respawn() -> Vector2:
	if not (respawn_position == null):
		return respawn_position
	
	respawn_position = RespawnManager.get_spawn_point(respawn_area)
	return respawn_position
