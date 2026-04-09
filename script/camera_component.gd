class_name CameraComponent

extends Camera2D

const MIN_OFFSET: int = 10
const DELTA_OFFSET: int = 100

var parent: CharacterBody2D
var stats: Stats
@onready var sprite: Sprite2D = $Sprite2D

var setupped: bool = false
var target_offset: Vector2 = Vector2(0, 0)
var debug: bool= true  #da spostare in autoload o impostazioni globali

func setup(statistics: Stats, player: CharacterBody2D) -> void:
	parent = player
	stats = statistics
	setupped = true
	if debug:
		sprite.visible = true

func _process(delta: float) -> void:
	if not setupped: return
	_update_offset(delta)
	sprite.position = offset

func _update_offset(delta: float) -> void:
	target_offset = _calc_offset()
	offset.x = move_toward(offset.x, target_offset.x, DELTA_OFFSET*delta)
	offset.y = move_toward(offset.y, target_offset.y, DELTA_OFFSET*delta)

func _calc_offset() -> Vector2:
	var target = Vector2(0, 0) 
	target.x = sign(parent.velocity.x)*clamp(abs(parent.velocity.x*stats.distance_n), MIN_OFFSET, stats.max_distance)
	target.y = sign(parent.velocity.y)*clamp(abs(parent.velocity.y*stats.distance_n), MIN_OFFSET, stats.max_distance)
	var mod: Vector2 = _offset_mod()
	target += mod
	return target 

func _offset_mod() -> Vector2:
	return Vector2(0, 0)
