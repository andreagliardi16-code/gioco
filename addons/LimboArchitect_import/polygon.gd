extends Resource
class_name Polygon

var id: String = ""
var points: PackedVector2Array = []

func _init(i: String, p: PackedVector2Array) -> void:
	id = i
	points = p
