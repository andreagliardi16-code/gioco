@tool

extends Area2D

class_name PogoableArea


@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	self.add_to_group(&"pogoable_areas")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if self.get_children().size() == 0:
		warnings.append("A shape must be assigned")
	
	return warnings


func _switch(on: bool) -> void:
	set_deferred("monitorable", on)
	set_deferred("monitoring", on)
