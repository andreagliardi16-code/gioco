@tool

class_name StaticPlatform

extends StaticBody2D


const ID: StringName = &"StaticPlatform"


@export var platform_material: PlatformMaterial = null:
	set(value):
		platform_material = value
		update_configuration_warnings()


func _ready() -> void:
	self.add_to_group(&"floor_areas")
	set_deferred("monitorable", true)


func _get_configuration_warnings() -> PackedStringArray:
	if platform_material == null:
		return ["A material must be assigned"]
	else:
		return []
