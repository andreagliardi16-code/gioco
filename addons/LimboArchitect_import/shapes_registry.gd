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


class Polygon:
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
var shapes_folder: String = ""
var db: Dictionary[String, LAShape] = {}
var import_shapes_dict: Dictionary[String, Callable] = {
	"Rectangle": Rectangle.new,
	"Circle": Circle.new,
	"Polygon": Polygon.new
}


func _init(shapes_dir: String) -> void:
	shapes_folder = shapes_dir


func _import_all_shapes() -> void:
	var dir: String = shapes_folder.path_join(shape_reg_name)
	var shapes_json: String = FileAccess.get_file_as_string(dir)
	
	# 1) svuoto tutto il folder delle risorse/forme
	# 2) importo l'array di tutte le forme salvate da shapes_json
	
	# 3) creo tutte le forme come .tres usando callv sull dizionario
	# 4) salvo tutto


func _create_LAshape(name: String, args: Array) -> Node2D:
	var callable: Callable = import_shapes_dict[name]
	return callable.callv(args)


func get_points(shape_id: String) -> PackedVector2Array:
	if not db.has(shape_id):
		push_error(shape_id, " non esiste.")
		return []
	elif not db[shape_id] is Polygon:
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
			rect.size = sh.size
			return rect
		LAShape.Type.CIRCLE:
			var circ = CircleShape2D.new()
			circ.radius = sh.radius
			return circ
		_: 
			push_error("Chiamata funzione sbagliata per creare poligono")
			return null
