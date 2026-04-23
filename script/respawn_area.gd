#area che determina l'assegnamento del punto di respawn
@tool

class_name RespawnArea

extends Area2D

@export var id: StringName = &""
@export var player_height: float = 80.0
@export var auto_update: bool = true
@export var update_now: bool:
	set(value):
		if value:
			update_spawn_point()

@onready var anchor: Marker2D = $Marker2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
		if not collision_shape:
			collision_shape = find_child("CollisionShape2D", true, false)
			
	update_spawn_point()

func _process(_delta: float) -> void:
	update_configuration_warnings()
	if Engine.is_editor_hint() and auto_update:
		
		if not collision_shape:
			collision_shape = find_child("CollisionShape2D", true, false)
			
		update_spawn_point()

func update_spawn_point() -> void:
	if collision_shape == null or anchor == null:
		return
	
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		var extents = shape.size/2.0
		
		var y = extents.y - player_height / 2.0
		
		anchor.position = Vector2.ZERO + Vector2(0,y)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if id == &"":
		warnings.append("Dare un identificativo adeguato all'area")
	if collision_shape == null:
		warnings.append("Aggiungere un nodo CollisionShape2D rettangolare come nodo figlio") 
	elif not collision_shape.shape:
		warnings.append("Aggiungere una forma alla CollisionShape2D")
	else:
		warnings.append("Assicurarsi che l'area sia tangente alla superficie di base")
	
	return warnings

func get_id() -> StringName: return id

func get_anchor_position() -> Vector2: 
	return anchor.global_position
