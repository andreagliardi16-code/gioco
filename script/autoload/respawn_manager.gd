extends Node

var spawn_point_list: Dictionary = {}

func build_spawn_points_map(root: Node2D) -> void:
	spawn_point_list.clear()
	
	var areas = root.find_children("*", "RespawnArea", true, false)
	print (areas)
	for i in range(areas.size()):
		spawn_point_list[areas[i].get_id()] = areas[i].get_anchor_position()

func get_spawn_point(identifier: StringName) -> Vector2:
	if spawn_point_list.has(identifier):
		return spawn_point_list[identifier]
	else:
		print("errore da: ", self)
		print("id cercato: ", identifier)
		return Vector2.ZERO
