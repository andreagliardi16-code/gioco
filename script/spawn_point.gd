#classe generale spawn point per creare mappa e abbinare posizione a id

class_name SpawnPoint

extends Resource

var id: StringName = &""
var position: Vector2 = Vector2.ZERO

func _init(name, pos) -> void:
	id = name
	position = pos
