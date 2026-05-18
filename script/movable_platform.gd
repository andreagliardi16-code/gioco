extends AnimatableBody2D
class_name MovablePlatform


@onready var sprite: Node2D = $WigglePivot

var platform_material: PlatformMaterial 


func _ready() -> void:
	self.add_to_group(&"floor_areas")
