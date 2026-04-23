extends Resource
class_name LevelMap

var levels: Dictionary[StringName, PackedScene] = {
	&"test_level": preload("res://scenes/levels/test_level.tscn"),
}
