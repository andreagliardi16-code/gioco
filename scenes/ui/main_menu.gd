class_name MainMenu

extends Control


func _on_button_pressed() -> void:
	LevelManager.change_level(&"test_level")
