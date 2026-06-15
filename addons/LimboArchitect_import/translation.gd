@tool
extends RefCounted
class_name LimboDataMapper

# IMPORTANTE: OLTRE A ADD_CHILD SETTARE SEMPRE LA PROPRIETà OWNER
# NEI NODI FIGLI PER PERMETTERE IL GIUSTO SALVATAGGIO

var _levels_dir: String = ""
var _level_data_dir: String = ""
var _shapes_registry

# TODO finire il dizionario dei percorsi, si potrebbero usare UID
var objects_path: Dictionary = {
	"StaticPlatform": "res://scenes/entities/game_obj/platform.tscn",
	"PolyPlatform": "res://scenes/entities/game_obj/platform.tscn",
	"LevelGate": "res://scenes/entities/game_obj/level_gate.tscn",
	"RespawnArea": "res://scenes/entities/game_obj/respawn_area.tscn"
}


# costruttore
func _init(levels: String, level_data: String, shapes_reg) -> void:
	_levels_dir = levels
	_level_data_dir = level_data
	_shapes_registry = shapes_reg


func _create_level(level_name: String, children_nodes: Array[Node]) -> PackedScene:
	var new_level = Node2D.new()
	var script = load("res://script/level.gd")
	
	new_level.set_script(script)
	
	for child in children_nodes:
		new_level.add_child(child)
		_set_owner_recursive(child, new_level)
	
	set_new_level(level_name, new_level as Level)
	
	var packed_level: PackedScene = PackedScene.new()
	var result = packed_level.pack(new_level)
	
	return result


func set_new_level(level_name: String, level: Level) -> void:
	level.level_id = level_name
	# TODO: aggiungere altri dati per il settaggio del livello


func _set_owner_recursive(node: Node, root: Node) -> void:
	node.owner = root
	for child in node.get_children():
		_set_owner_recursive(child, root)


#region objects factories
# 1. La funzione helper che fa tutto il lavoro ripetitivo
func _create_base_platform(gd_class_name: String, x: int, y: int) -> StaticPlatform:
	var platform_scene: PackedScene = load(objects_path[gd_class_name])
	var new_platform = platform_scene.instantiate() as StaticPlatform
	
	new_platform.position = Vector2(x, y)
	new_platform.platform_material = load("uid://dhbylf6lt2h47")
	new_platform.set_collision_layer_value(1, true)
	new_platform.set_collision_layer_value(2, true)
	new_platform.set_collision_mask_value(1, true)
	
	return new_platform


# 2. La fabbrica per le piattaforme RETTANGOLARI diventa cortissima
func _static_platform_factory(gd_class_name: String, shape_id: String, x: int, y: int) -> StaticPlatform:
	var new_platform = _create_base_platform(gd_class_name, x, y)
	
	var s: RectangleShape2D = RectangleShape2D.new()
	s.size = _shapes_registry.get_size(shape_id)
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_platform.add_child(collision)
	
	return new_platform


# 3. La fabbrica per le piattaforme POLIGONALI diventa altrettanto pulita
func _poly_platform_factory(gd_class_name: String, shape_id: String, x: int, y: int) -> StaticPlatform:
	var new_platform = _create_base_platform(gd_class_name, x, y)
	
	var points: PackedVector2Array = _shapes_registry.get_points(shape_id)
	var collision: CollisionPolygon2D = CollisionPolygon2D.new()
	collision.polygon = points
	new_platform.add_child(collision)
	
	return new_platform


func _level_gate_factory(gd_class_name: String, x: int, y: int, 
	shape_id: String, own_ptr: String, gate_ptr: String, 
	own_level_ptr: String, next_level_ptr: String) -> LevelGate:
	
	var gate: PackedScene = load(objects_path[gd_class_name])
	var new_gate: LevelGate = gate.instantiate() as LevelGate
	
	new_gate.position = Vector2(x, y)
	new_gate.set_collision_layer_value(1, true)
	new_gate.set_collision_layer_value(2, true)
	new_gate.set_collision_mask_value(1, true)
	
	var collision = new_gate.get_node("CollisionShape2D") as CollisionShape2D
	var s: RectangleShape2D = RectangleShape2D.new()
	s.size = _shapes_registry.get_size(shape_id)
	collision.shape = s
	
	new_gate.gate_ptr = gate_ptr
	new_gate.level_ptr = next_level_ptr
	new_gate.own_ptr = own_ptr
	
	return new_gate


func _spawn_area_factory() -> void:
	pass


func _killzone_factory() -> void:
	pass


func _static_pogo_area_factory() -> void:
	pass


func _timed_pogo_area_factory() -> void:
	pass
#endregion
