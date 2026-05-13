extends Node2D
## Remember to open "Editable Children"!

@export_multiline var README = "Right click and enable editable children!" ## Important to do this if you want to use properly[br]Enable Editable Children!
@export var platform_material: PlatformMaterial = null

@onready var platform: AnimatableBody2D = $Platform


func _ready() -> void:
	platform.platform_material  = platform_material
