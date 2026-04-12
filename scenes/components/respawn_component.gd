# componente legata al player che memorizza l'ultima area di respawn attraversata
# attraverso la sua posizione o l'id, quando selezionato da editor

class_name RespawnComponent

extends Node

const DEF_RESPAWN: Vector2 = Vector2(0,0)

@export var respawn_area: StringName = &"empty"

var respawn_position: Vector2 = DEF_RESPAWN
