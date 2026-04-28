@tool

extends Area2D

class_name PoagoableArea


@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	self.add_to_group(&"pogoable_areas")


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
