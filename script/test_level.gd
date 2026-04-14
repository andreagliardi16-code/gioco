extends Node2D

func _ready() -> void:
	RespawnManager.build_spawn_points_map(self)
