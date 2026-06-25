@tool

extends EditorPlugin

class_name JSON_data_bridge


const ENTITIES_CONFIG_PATH: String = "res://ext_game_data/game_entities.json"
const ENTITIES_PATH: String = "res://scenes/entities/game_obj"
const LEVEL_REGISTER_PATH: String = "res://ext_levels/lvl_register"
const IMPORTED_LEVELS_PATH: String = "res://ext_levels/imported_levels/"
const EXPORTED_LEVELS_PATH: String = "res://ext_levels/exported_levels/"
const SHAPES_FOLDER: String = "res://ext_game_data/external_shapes/"


## percorso della cartella in cui sono contenuti i file .tscn dei livelli di gioco
@export var levels_folder_path: String = "res://scenes/levels/"
## percorso della cartella con i level_data
@export var level_data_path: String = "res://data/levels/"


var shapes_registry: ShapesRegistry
var level_builder: LimboDataMapper


func _enter_tree() -> void:
	shapes_registry = ShapesRegistry.new(SHAPES_FOLDER, "Mettere Giusto Percorso", json_to_array)
	level_builder = LimboDataMapper.new(levels_folder_path, level_data_path, shapes_registry)
	self.check_level_register()


#region levels
## Paragono il registro dei livelli già importati con quelli effettivamente fatti in LA
## per vedere se devo importarne di nuovi
func check_level_register() -> void:
	var registry_text = FileAccess.get_file_as_string(LEVEL_REGISTER_PATH)
	if registry_text == "":
		push_warning("Registro dei livelli vuoto. Operazione di import bloccata")
		return
	
	## Controllo che i livelli registrati corrispondano a quelli esportati
	# 1) rendo il json nel file una lista semplice
	var level_id_reg: Array = json_to_array(registry_text)
	
	# 2) apro la cartella con i livelli importati da LA e creo una lista con gli ID
	var imp_levels_list: Array = _get_imported_levels()
	
	# 3) Controllo se le due liste sono uguali. Se un id manca, devo importare un nuovo livello.
	var levels_to_import: Array = []
	
	for level_name in imp_levels_list:
		if level_name not in level_id_reg:
			levels_to_import.append(level_name)
	
	# Se non ci sono nuovi livelli da importare, interrompiamo qui senza fare nulla
	if levels_to_import.is_empty():
		print("Registro già aggiornato. Nessun nuovo livello da importare.")
		return
	
	# 4) Passo gli id dei livelli da importare a una funzione specializzata
	var err: Global.Outcome = import_levels(levels_to_import)
	
	if not err == Global.Outcome.OK:
		push_error("Impossibile importare i livelli da LA")
		return
	
	# 5) Aggiungo i livelli importati al registro
	level_id_reg.append_array(levels_to_import)
	level_id_reg.sort()
	var json_registry = JSON.stringify(level_id_reg, "\t")
	var registry = FileAccess.open(LEVEL_REGISTER_PATH, FileAccess.WRITE)
	registry.store_string(json_registry)


## Importo i livelli da un array di nomi caricando direttamente i relativi file JSON
func import_levels(levels_to_import: Array[String]) -> Global.Outcome:
	for level_name in levels_to_import:
		var file_path = IMPORTED_LEVELS_PATH.path_join(level_name + ".json")
		
		if FileAccess.file_exists(file_path):
			var file_text = FileAccess.get_file_as_string(file_path)
			if file_text != "":
				var level_info = JSON.parse_string(file_text)
				
				if level_info != null and level_info.has("name"):
					var build_outcome = _build_level(level_info)
					if build_outcome == Global.Outcome.FAIL:
						return Global.Outcome.FAIL
				else:
					print("File JSON corrotto o malformato: ", file_path)
		else:
			print("Livello richiesto non trovato nella cartella degli import: ", level_name)
			
	return Global.Outcome.OK


func _get_imported_levels() -> Array:
	var dir = DirAccess.open(IMPORTED_LEVELS_PATH)
	if not dir:
		print("Errore nella ricerca della cartella : ", IMPORTED_LEVELS_PATH)
		return []
	
	var imp_levels_list: Array = []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var full_path: String
	while file_name != "":
		# Ignoriamo le cartelle e i file nascosti di sistema (es. .DS_Store su Mac o nodi speciali)
		if not dir.current_is_dir() and not file_name.begins_with("."):
			full_path = IMPORTED_LEVELS_PATH.path_join(file_name) 
			var curr_file_text = FileAccess.get_file_as_string(full_path)
			
			if curr_file_text != "":
				var level_info = JSON.parse_string(curr_file_text)
				
				# Controllo di sicurezza: verifichiamo che il JSON sia valido e abbia la chiave "name"
				if level_info != null and level_info.has("name"):
					# Evitiamo duplicati nella lista temporanea dei file fisici
					if not imp_levels_list.has(level_info["name"]):
						imp_levels_list.append(level_info["name"])
				else:
					print("File salvato male o corrotto in imported_levels: ", file_name)
		
		file_name = dir.get_next()
	
	return imp_levels_list


func _build_level(level: Dictionary) -> Global.Outcome:
	# 1) Estraggo informazioni principali
	var level_name = level["name"]
	var level_items_list: Array[Dictionary] = level["items"]
	
	# 2) Prima creo l'array di nodi figli
	var real_items: Array = []
	
	for item in level_items_list:
		# Sostituisci il ciclo "for key in item" con questo:
		var item_name: String = item.get("name", "")
		var item_args: Array = []

		# 1. Inseriamo i 4 parametri base nell'ordine esatto richiesto dalle factory
		item_args.append(item_name)
		item_args.append(item.get("shape_id", ""))
		item_args.append(int(item.get("x", 0)))
		item_args.append(int(item.get("y", 0)))

		# 2. Aggiungiamo i parametri extra solo se l'oggetto lo richiede
		match item_name:
			"LevelGate":
				item_args.append(item.get("own_ptr", ""))
				item_args.append(item.get("gate_ptr", ""))
				item_args.append(item.get("own_level_ptr", ""))
				item_args.append(item.get("next_level_ptr", ""))
			"TimedPogoableArea":
				item_args.append(float(item.get("timer", 1.0)))
		
		var obj = level_builder.create_object(item_name, item_args)
		if not obj == null:
			real_items.append(obj)
	
	# 3) Poi creo il livello vero e proprio
	var packed_level: PackedScene = level_builder.create_level_wrap(level_name, real_items)
	
	# 3) Infine uso il metodo che lo salva su disco
	var err = level_builder.save_level(packed_level, level_name)
	if err != Global.Outcome.OK:
		push_error("Impossibile salvare il livello: ", level_name)
		return Global.Outcome.FAIL
	else:
		return Global.Outcome.OK
#endregion


func json_to_array(file_string: String) -> Array:
	var ttt = JSON.parse_string(file_string)
	
	if not ttt is Array:
		print("Il file non è stato salvato correttamente")
		return [Global.Outcome.FAIL]
	
	return ttt
