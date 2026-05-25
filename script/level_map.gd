@tool

extends Resource
class_name LevelMap


@export var levels_directory: String = "res://data/levels/"

var levels: Dictionary[StringName, LevelData]


# creo un dizionario, a partire dalla cartella levels, in cui vengono 
# salvate tutte le risorse .tres dei levelData, con i percorsi 
# delle scene per caricarle, I loro id, e tutte le loro entrate.
func reload_level_db() -> void:
	levels.clear()
	var dir = DirAccess.open(levels_directory)
	
	if not dir:
		push_error("Impossibile accedere alla cartella dei livelli: ", levels_directory)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while not file_name == "":
		if not dir.current_is_dir():
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
				
				if file_name.ends_with(".remap"):
					file_name = file_name.trim_suffix(".remap")
				
				var full_path = levels_directory + file_name
				var data = load(full_path)
				
				if data is LevelData:
					#print(data)
					levels[data.level_id] = data
		
		file_name = dir.get_next()
	
	print("LevelMap inizializzata con successo. Livelli caricati: ", levels.keys())


func has_gate(level: StringName, _level_gate: StringName) -> bool:
	if not levels.has(level):
		push_warning("Livello non presente nel dizionario: ", level)
		return false
	
	return true
