extends AnimatableBody2D
class_name MovablePlatform


const ID: StringName = &"MovablePlatform"


var platform_material: PlatformMaterial 


func _ready() -> void:
	self.add_to_group(&"floor_areas")
