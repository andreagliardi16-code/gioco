@tool

extends Resource
class_name LevelData


var level_id: StringName 
var entrances: Array[StringName]


func add_entrance(id: StringName) -> Global.Outcome:
	if entrances.has(id):
		return Global.Outcome.FAIL
	
	else: 
		entrances.append(id)
		return Global.Outcome.OK

func _init(id: StringName) -> void:
	level_id = id
