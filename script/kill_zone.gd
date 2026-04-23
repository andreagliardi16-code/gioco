@tool

extends Area2D
class_name KillZone

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if self.get_children().size() == 0:
		warnings.append("A shape must be assigned")
	
	else:
		warnings.append("")
	
	return warnings


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	
	body.die()
