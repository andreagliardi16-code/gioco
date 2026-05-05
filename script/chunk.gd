# oggetto che si occupa di gestire l'attivazione e la disattivazione
# dei suoi nodi figli. Serve per tenere framerate stabile in stanze molto
# grandi, disattivando visibilità, fisica e script dei suoi nodi figli se 
# troppo lontani dal player
@tool


extends Node2D
class_name Chunk


enum State {ON, OFF}


var curr_state: State = State.OFF

var area: Area2D = null


func _ready() -> void:
	area = $"Area2D"
	
	update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var string: PackedStringArray
	
	if area == null:
		string.append("Nessuna area assegnata, il chunk non può essere attivato")
	
	return string
