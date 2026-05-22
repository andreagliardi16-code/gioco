class_name MainMenu

extends Control

var game_manager: GameManager = null
@onready var button = $Button

func _ready():
	print("MAIN MENU INSTANCE:", get_instance_id())

func setup(node: GameManager) -> void:
	game_manager = node

func _on_button_pressed() -> void:
	queue_free()
	print("global_spawn: ", Global.spawn_level_id)
	game_manager.change_level(Global.spawn_level_id)
