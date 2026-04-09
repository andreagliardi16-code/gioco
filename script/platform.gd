@tool

class_name StaticPlatform

extends StaticBody2D

var value

@export var platform_material: PlatformMaterial = null:
	set(value):
		platform_material = value
		update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if platform_material == null:
		return ["A material must be assigned"]
	else:
		return []
