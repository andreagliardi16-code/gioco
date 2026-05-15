@tool

extends Node2D
class_name Level


signal level_exited(level_id: StringName, gate_id: StringName)


@export var refresh_entrances_now: bool:
	set(value):
		if value:
			_create_entrances_list()
@export var level_id: StringName:
	set(value):
		old_id = level_id
		level_id = value
@export var update_resource: bool:
	set(value):
		if value:
			_create_level_data_resource()
@export var level_data: LevelData

var entrances: Array[LevelGate] = []
var old_id: StringName = &""


#region timer, process e ready
func _ready() -> void:
	if Engine.is_editor_hint():
		_create_level_data_resource()
	else:
		_create_entrances_list()
		self.add_to_group(&"levels")
#endregion


#region LevelData e entrances list
func _create_level_data_resource():
	if level_id == &"": 
		print("ozz")
		return
	
	var path: String = "res://data/levels/" + str(level_id) + ".tres"
	
	if old_id != &"" and old_id != level_id:
		var old_path = "res://data/levels/" + str(old_id) + ".tres"
		if FileAccess.file_exists(old_path):
			DirAccess.rename_absolute(old_path, path)
			print("Risorsa rinominata da ", old_id, " a ", level_id)
	
	# Se il file non esiste, lo creiamo e lo salviamo
	var data: LevelData
	
	if FileAccess.file_exists(path):
		data = load(path) as LevelData
	else:
		data = LevelData.new()
	
	data.level_id = level_id
	data.scene_path = scene_file_path
	
	data.emit_changed()
	
	print("Sto salvando:")
	print("level_id =", data.level_id)
	print("scene_path =", data.scene_path)
	print("scene_entrances =", data.entrances)
	
	var err = ResourceSaver.save(data, path)
	if err != OK:
		push_error("Errore nel salvataggio: " + str(err))
	
	level_data = data
	print("Sincronizzazione completata per: ", level_id, " -> ", path)
	
	old_id = level_id


func _create_entrances_list() -> void:
	entrances.clear() #svuoto l'array per evitare duplicazioni
	
	for child in get_children():
		if child is LevelGate:
			entrances.append(child)
			_connect_entrance(child)
	print("entrate: ", entrances)
	
	if entrances.size() < 1:
		push_warning("Il livello dovrebbe avere almeno un entrata/uscita")


func _connect_entrance(gate: LevelGate) -> void:
	print("Gate connected")
	if not gate.new_gate_id.is_connected(_on_new_gate_id):
		gate.new_gate_id.connect(_on_new_gate_id)
		gate.gate_entered.connect(_on_gate_entered)


func _on_new_gate_id(new_id: StringName, old_gate_id: StringName, gate: LevelGate) -> void:
	if entrances.has(gate):
		print("modifico entrata")
		var flag: Global.Outcome = level_data.modify_entrance(new_id, old_gate_id)
		if flag == Global.Outcome.FAIL:
			push_warning("old_gate_id non trovato in level data, aggiungo new_gate_id")
			level_data.add_entrance(new_id)
	
	else:
		print("aggiungo entrata")
		level_data.add_entrance(new_id)
#endregion


#region gate
func _on_gate_entered(gate_ptr: StringName, level_ptr: StringName) -> void:
	emit_signal("level_exited", level_ptr, gate_ptr)


func get_gate_pos(gate_id: StringName) -> Vector2:
	for i in range(entrances.size()):
		if entrances[i].own_ptr == gate_id:
			var pos := entrances[i].marker.global_position
			return pos
	
	push_error("entrata non trovata")
	return Vector2.ZERO
#endregion
