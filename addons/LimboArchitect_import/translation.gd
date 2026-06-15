@tool
extends RefCounted
class_name LimboDataMapper

# IMPORTANTE: OLTRE A ADD_CHILD SETTARE SEMPRE LA PROPRIETà OWNER
# NEI NODI FIGLI PER PERMETTERE IL GIUSTO SALVATAGGIO

var _levels_dir: String = ""
var _level_data_dir: String = ""


# costruttore
func _init(levels: String, level_data: String) -> void:
	_levels_dir = levels
	_level_data_dir = level_data


func _create_level(level_name: String, children_nodes: Array[Node]) -> PackedScene:
	var new_level = Node2D.new()
	var script = load("res://script/level.gd")
	
	new_level.set_script(script)
	
	for child in children_nodes:
		new_level.add_child(child)
		child.owner = new_level
	
	set_new_level(level_name, new_level)
	
	var packed_level: PackedScene = PackedScene.new()
	var result = packed_level.pack(new_level)
	
	return result


func set_new_level(level_name: String, level: Level) -> void:
	level.level_id = level_name
	# TODO: aggiungere altri dati per il settaggio del livello
