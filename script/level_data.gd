@tool

extends Resource
class_name LevelData


@export var level_id: StringName 
@export var scene_path: String
@export var entrances: Array[StringName]


func add_entrance(id: StringName) -> Global.Outcome:
	if entrances.has(id):
		return Global.Outcome.FAIL
	
	else: 
		entrances.append(id)
		return Global.Outcome.OK


func modify_entrance(new_id: StringName, old_id: StringName) -> Global.Outcome:
	print("modifico entrata in LevelData")
	if not entrances.has(old_id):
		return Global.Outcome.FAIL
	
	var i = entrances.find(old_id)
	entrances[i] = new_id
	
	print("Entrances in LevelData: ", entrances)
	
	return Global.Outcome.OK


func find_entrances(id: StringName) -> bool:
	for i in range(entrances.size()):
		if entrances[i] == id:
			return true
	
	return false
