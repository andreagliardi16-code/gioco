extends Resource

class_name JSON_data_bridge


const CONFIG_PATH: String = "res://ext_game_data/game_data.json"


@export var player_stats: PlayerStats
@export var physics_stats: PhysicsStats

func _load_from_json() -> void:
	if not FileAccess.file_exists(CONFIG_PATH) or not player_stats or not physics_stats:
		return
	
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_string :String = file.get_as_text()
	file.close()
	
	var json :JSON = JSON.new()
	if not JSON.parse_string(json_string) == OK:
		push_error("Impossibile leggere il file json")
		return
	
	#altrimenti creo il dizionario corrispondente al json e metto i valori nei dizionari
