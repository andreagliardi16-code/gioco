extends Resource
class_name LevelMap

var levels: Dictionary[StringName, Dictionary] = {
	&"test": {
		"instance" : preload("res://scenes/levels/test_level.tscn"),
		"data" : LevelData.new(&"test")
		},
	&"tutorial": {
		"instance" : preload("res://scenes/levels/tutorial_level.tscn"),
		"data" : LevelData.new(&"tutorial")
	}
}
