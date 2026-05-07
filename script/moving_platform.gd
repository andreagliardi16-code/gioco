extends Path2D


@export var movement_curve: Curve = null
@export var m_platform: PackedScene = null
@export var period: float = 0.0

@onready var path_follow: PathFollow2D = $PathFollow2D

var platform: MovablePlatform = null
var time_prog: float = 0.0


func _ready() -> void:
	if m_platform:
		platform = m_platform.instantiate()
		path_follow.add_child(platform)


func _physics_process(_delta: float) -> void:
	_move()


func _move() -> void:
	time_prog = _get_time_prog()
	
	var curve_value: float = time_prog
	
	if not movement_curve == null:
		curve_value = movement_curve.sample(time_prog)
	
	_apply_offset(curve_value)


func _get_time_prog() -> float:
	var time: float = TimeManager.get_time()
	
	var progress: float = fmod(time, period) / period
	
	return progress


func _apply_offset(value: float) -> void:
	if value < 0 or value > 1:
		push_error("la funzione calcola un valore di posizione sbagliato: ", value)
		return
	
	path_follow.progress_ratio = value
