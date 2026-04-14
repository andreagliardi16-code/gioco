extends Node

var levels: Dictionary[StringName, PackedScene] = {
	&"test_level": preload("res://scenes/levels/test_level.tscn"),
}

func change_level(id: StringName) -> void:
	get_tree().change_scene_to_packed(levels[id])
