@tool
extends RefCounted
class_name ShapesRegistry


#region Classi di forme
@abstract class LAShape:
	enum Type {RECTANGLE, CIRCLE, POLYGON}
	
	var shape_type: Type
	var id: String
	
	func _init() -> void:
		pass


class Rectangle:
	extends LAShape
	
	var size: Vector2
	
	func _init(size_x: float, size_y: float, s: String) -> void:
		size = Vector2(size_x, size_y)
		shape_type = LAShape.Type.RECTANGLE
		id = s
	func get_size() -> Vector2:
		return size


class Circle: 
	extends LAShape
	
	var radius: float
	
	func _init(r: float, s: String) -> void:
		radius = r
		shape_type = LAShape.Type.CIRCLE
		id = s
	func get_radius() -> float:
		return radius


class Poly:
	extends LAShape
	
	var points: PackedVector2Array = []
	
	func _init(p: Array, s: String)-> void:
		points = p
		shape_type = LAShape.Type.POLYGON
		id = s
	func get_points() -> PackedVector2Array:
		return points
#endregion


var shape_reg_name: String = "shapes_reg"
var shapes_folder: String = ""             # directory del json con le forme
var shapes_res_folder: String = ""         # directory delle risorse forma e poligono
var json_parser: Callable
var db: Dictionary[String, LAShape] = {}
var import_shapes_dict: Dictionary[String, Callable] = {
	"Rectangle": Rectangle.new,
	"Circle": Circle.new,
	"Polygon": Polygon.new
}


func _init(shapes_dir: String, res_dir: String, json_to_array: Callable) -> void:
	shapes_folder = shapes_dir
	json_parser = json_to_array
	shapes_res_folder = res_dir


func _import_all_shapes() -> void:
	var dir: String = shapes_folder.path_join(shape_reg_name)
	var shapes_json: String = FileAccess.get_file_as_string(dir)
	
	# 1) svuoto tutto il folder delle risorse/forme e il dizionario
	_clear_resource_folder(shapes_res_folder)
	db.clear()
	
	# 2) importo l'array di tutte le forme salvate da shapes_json
	var shapes_arr: Array[Dictionary] = json_parser.call(shapes_json)
	
	# 3) creo tutte le forme come .tres usando callv sull dizionario e le salvo in DB
	for shape_data: Dictionary in shapes_arr:
		var type_string: String = shape_data.get("type", "") # es. "Rectangle"
		var id_string: String = shape_data.get("id", "")
		var args: Array = shape_data.get("args", []) # Gli argomenti per il costruttore: es. [10.0, 20.0, "rect_id"]
		
		if import_shapes_dict.has(type_string):
			var la_shape: LAShape = _create_LAshape(type_string, args)
			db[id_string] = la_shape
			
			# 4) SALVATAGGIO: Generiamo il .tres nativo corrispondente per Godot
			_save_shape_as_tres(la_shape)
		else:
			push_error("Tipo forma sconosciuto nel JSON: ", type_string)


func _create_LAshape(name: String, args: Array) -> LAShape:
	var callable: Callable = import_shapes_dict[name]
	return callable.callv(args) as LAShape


func _clear_resource_folder(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".res")):
				dir.remove(file_name)
			file_name = dir.get_next()


func _save_shape_as_tres(sh: LAShape) -> void:
	var gd_shape: Shape2D = _create_gd_shape(sh)
	if gd_shape == null:
		var poly: Polygon = Polygon.new(sh.id, (sh as Poly).points)
		var file_path: String = shapes_res_folder.path_join(sh.id + ".tres")
		ResourceSaver.save(poly, file_path)
		return
	
	var file_path: String = shapes_res_folder.path_join(sh.id + ".tres")
	ResourceSaver.save(gd_shape, file_path)


func get_points(shape_id: String) -> PackedVector2Array:
	if not db.has(shape_id):
		push_error(shape_id, " non esiste.")
		return []
	elif not db[shape_id] is Poly:
		push_error(shape_id, " non è un poligono")
		return []
	else:
		return db[shape_id].get_points()


func get_shape(shape_id: String) -> Shape2D:
	if not db.has(shape_id):
		return null
	
	var shape = db[shape_id]
	return _create_gd_shape(shape)


func _create_gd_shape(sh: LAShape) -> Shape2D:
	match sh.shape_type:
		LAShape.Type.RECTANGLE:
			var rect = RectangleShape2D.new()
			rect.size = (sh as Rectangle).size
			return rect
		LAShape.Type.CIRCLE:
			var circ = CircleShape2D.new()
			circ.radius = (sh as Circle).radius
			return circ
		_: 
			push_error("Chiamata funzione sbagliata per creare poligono")
			return null
