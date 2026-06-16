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
	"RespawnArea": "res://scenes/entities/game_obj/respawn_area.tscn",
	"KillZone": "res://scenes/entities/game_obj/kill_zone.tscn",
	"PogoableArea": "res://scenes/entities/game_obj/pogoable_area.tscn",
	"TimedPogoableArea": "res://scenes/entities/game_obj/timed_pogoable_area.tscn"
}


var factories: Dictionary[String, Callable] = {
	"StaticPlatform": _static_platform_factory,
	"PolyPlatform": _poly_platform_factory,
	"LevelGate": _level_gate_factory, 
	"RespawnArea": _spawn_area_factory,
	"KillZone": _killzone_factory,
	"PogoableArea": _static_pogo_area_factory,
	"TimedPogoableArea": _timed_pogo_area_factory
}


# costruttore
func _init(levels: String, level_data: String, shapes_reg) -> void:
	_levels_dir = levels
	_level_data_dir = level_data
	_shapes_registry = shapes_reg


func create_object(obj_type: String, args: Array) -> Node2D:
	if not factories.has(obj_type):
		push_error("Il tipo di oggetto non esiste: ", obj_type)
		return null
	
	var callable: Callable = factories[obj_type]
	if args.size() != callable.get_argument_count():
		push_error("Errore argomenti per ", obj_type, ": il JSON ha ", args.size(), " parametri, ma la factory ne richiede ", callable.get_argument_count())
		return null
	var new_object = callable.callv(args)
	
	return new_object


#region level factory e save
func create_level_wrap(level_name: String, children_nodes: Array[Node]) -> PackedScene:
	var new_level = Node2D.new()
	var script = load("res://script/level.gd")
	
	new_level.set_script(script)
	
	for child in children_nodes:
		new_level.add_child(child)
		_set_owner_recursive(child, new_level)
	
	_set_new_level(level_name, new_level as Level)
	
	var packed_level: PackedScene = PackedScene.new()
	var result = packed_level.pack(new_level)
	
	return result


func _set_new_level(level_name: String, level: Level) -> void:
	level.level_id = level_name
	# TODO: aggiungere altri dati per il settaggio del livello


func _set_owner_recursive(node: Node, root: Node) -> void:
	node.owner = root
	for child in node.get_children():
		_set_owner_recursive(child, root)


func save_level(level: PackedScene, level_name: String) -> Global.Outcome:
	if _levels_dir == "":
		push_error("Errato percorso alla cartella dei livelli")
		return Global.Outcome.FAIL
	
	var save_path: String = _levels_dir.path_join(level_name + ".tscn")
	var err = ResourceSaver.save(level, save_path)
	
	if not err == OK:
		push_error("Impossibile salvare il livello su disco! Errore: ", err)
		return Global.Outcome.FAIL
	else:
		return Global.Outcome.OK
#endregion


#region objects factories
# Funzione helper che fa lavoro ripetitivo
func _set_physic_properties(new_obj: Node2D, x: int, y: int) -> void:
	new_obj.position = Vector2(x, y)
	
	new_obj.set_collision_layer_value(1, true)
	new_obj.set_collision_layer_value(2, true)
	new_obj.set_collision_mask_value(1, true)


# Funzione helper che fa lavoro ripetitivo
func _create_base_platform(gd_class_name: String, x: int, y: int) -> StaticPlatform:
	var platform_scene: PackedScene = load(objects_path[gd_class_name])
	var new_platform = platform_scene.instantiate() as StaticPlatform
	
	new_platform.platform_material = load("uid://dhbylf6lt2h47")
	self._set_physic_properties(new_platform, x, y)
	
	return new_platform


#  La fabbrica per le piattaforme RETTANGOLARI
func _static_platform_factory(gd_class_name: String, shape_id: String, 
	x: int, y: int) -> StaticPlatform:
	var new_platform = _create_base_platform(gd_class_name, x, y)
	
	var s: RectangleShape2D = _shapes_registry.get_shape(shape_id) as RectangleShape2D
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_platform.add_child(collision)
	
	return new_platform


#  La fabbrica per le piattaforme POLIGONALI
func _poly_platform_factory(gd_class_name: String, shape_id: String, x: int, y: int) -> StaticPlatform:
	var new_platform = _create_base_platform(gd_class_name, x, y)
	
	var points: PackedVector2Array = _shapes_registry.get_points(shape_id)
	var collision: CollisionPolygon2D = CollisionPolygon2D.new()
	collision.polygon = points
	new_platform.add_child(collision)
	
	return new_platform


#  Factory per i Gate
func _level_gate_factory(gd_class_name: String, shape_id: String, 
	 x: int, y: int, own_ptr: String, gate_ptr: String, 
	own_level_ptr: String, next_level_ptr: String) -> LevelGate:
	
	var gate: PackedScene = load(objects_path[gd_class_name])
	var new_gate: LevelGate = gate.instantiate() as LevelGate
	
	self._set_physic_properties(new_gate, x, y)
	
	var collision = new_gate.get_node("CollisionShape2D") as CollisionShape2D
	var s: RectangleShape2D = _shapes_registry.get_shape(shape_id) as RectangleShape2D
	collision.shape = s
	
	new_gate.gate_ptr = gate_ptr
	new_gate.level_ptr = next_level_ptr
	new_gate.own_ptr = own_ptr
	
	return new_gate


#  Factory per i respawn
func _spawn_area_factory(gd_class_name: String, shape_id: String,
	x: int, y: int ) -> RespawnArea:
	
	var spawn: PackedScene = load(objects_path[gd_class_name])
	var new_spawn: RespawnArea = spawn.instantiate() as RespawnArea
	
	self._set_physic_properties(new_spawn, x, y)
	
	var s: RectangleShape2D = _shapes_registry.get_shape(shape_id) as RectangleShape2D
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_spawn.add_child(collision)
	
	return new_spawn


#  Factory per le zone di danno
func _killzone_factory(gd_class_name: String, shape_id: String,
	x: int, y: int) -> KillZone:
	
	var killzone: PackedScene = load(objects_path[gd_class_name])
	var new_killzone: KillZone = killzone.instantiate() as KillZone
	
	self._set_physic_properties(new_killzone, x, y)
	
	# Possibile problema. Killzone può avere diverse forme
	var s: Shape2D = _shapes_registry.get_shape(shape_id) as Shape2D
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_killzone.add_child(collision)
	
	return new_killzone


func _static_pogo_area_factory(gd_class_name: String, shape_id: String,
	x: int, y: int) -> PogoableArea:
	
	var pogo: PackedScene = load(objects_path[gd_class_name])
	var new_pogo: PogoableArea = pogo.instantiate() as PogoableArea
	
	self._set_physic_properties(new_pogo, x, y)
	
	var s: Shape2D = _shapes_registry.get_shape(shape_id) as Shape2D
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_pogo.add_child(collision)
	
	return new_pogo


func _timed_pogo_area_factory(gd_class_name: String, shape_id: String,
	x: int, y: int, timer: float) -> TimedPogoableArea:
	
	var timed_pogo: PackedScene = load(objects_path[gd_class_name])
	var new_timed_pogo: TimedPogoableArea = timed_pogo.instantiate() as TimedPogoableArea
	
	self._set_physic_properties(new_timed_pogo, x, y)
	
	var s: Shape2D = _shapes_registry.get_shape(shape_id) as Shape2D
	
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = s
	new_timed_pogo.add_child(collision)
	
	return new_timed_pogo
#endregion
