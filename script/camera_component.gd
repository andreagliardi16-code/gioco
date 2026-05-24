class_name CameraComponent

extends Camera2D


const DEF_OFFSET: Vector2 = Vector2.ZERO
const DELTA_OFFSET: int = 100
const TRANSITION_TIME: float = 1.0
const MAX_SPEED_X: float = 1923.26568097217
const MAX_SPEED_Y: float = 1121.9049805671


enum State {DEFAULT, PAN_TRANSITION, PAN}


var parent: CharacterBody2D
var stats: Stats

@export var pan_curve: Curve = null

@onready var sprite: Sprite2D = $Sprite2D

var curr_cam_state: State = State.DEFAULT
var setupped: bool = false
var target_offset: Vector2 = Vector2(0, 0)
var debug: bool= true  #da spostare in autoload o impostazioni globali
var transition_timer: float = 0.0
var pan_direction: Global.Direction = Global.Direction.NULL
var curve_area  #serve per determinare MAX_SPEED in fase di testing
var going_up: bool = false
var last_sign: int = 1


func setup(statistics: Stats, player: CharacterBody2D) -> void:
	parent = player
	stats = statistics
	
	setupped = true
	
	if Global.debug_mode:
		sprite.visible = true
		#curve_area = _calculate_curve_area(pan_curve, 100)
		#_calc_max_speed()
	else:
		sprite.visible = false
		sprite.process_mode = Node.PROCESS_MODE_DISABLED


## Calcola l'area sottesa alla curva campionandola in N passi (Riemann Sum)
func _calculate_curve_area(curve: Curve, samples: int) -> float:
	var total_area: float = 0.0
	var step: float = 1.0 / samples
	
	for i in range(samples):
		var t = i * step
		# Approssimiamo l'area di ogni piccolo rettangolo
		total_area += curve.sample(t) * step
	
	return total_area


func _calc_max_speed() -> void:
	var distance_x = stats.x_pan_target
	var distance_y = stats.y_pan_target
	print("MAX_SPEED_X = ",distance_x / (TRANSITION_TIME * curve_area))
	print("MAX_SPEED_Y = ",distance_y / (TRANSITION_TIME * curve_area))


func _process(delta: float) -> void:
	if not setupped: return
	_update_offset(delta)
	_handle_timers(delta)
	
	sprite.position = offset


func _handle_timers(delta: float) -> void:
	if transition_timer > 0:
		transition_timer -= delta
		if transition_timer <= 0:
			_end_pan_transition()
			transition_timer = 0


func _update_offset(delta: float) -> void:
	match curr_cam_state:
		State.DEFAULT:
			target_offset= _calc_offset()
			offset.x = move_toward(offset.x, target_offset.x, DELTA_OFFSET*delta)
			offset.y = move_toward(offset.y, target_offset.y, DELTA_OFFSET*delta)
		State.PAN_TRANSITION:
			_handle_pan_transition(delta)


#region normal_offset
func _calc_offset() -> Vector2:
	var target = Vector2(0, 0) 
	target.x = _calc_offset_x()
	target.y = _calc_offset_y()
	return target 


func _calc_offset_x() -> float:
	return sign(parent.velocity.x) * clamp(abs(parent.velocity.x*stats.distance_n), 0.0, stats.max_distance)


func _calc_offset_y() -> float:
	if sign(parent.velocity.y) < 0: going_up = true
	else: going_up = false
	
	if not going_up:  #nel caso stia cadendo calcolo normalmente
		return sign(parent.velocity.y) * clamp(abs(parent.velocity.y*stats.distance_n), 0.0, stats.max_distance)
	
	#nel caso si stia muovendo verso l'alto:
	return clamp(-parent.velocity.y, 0.0, stats.max_distance)
#endregion


#region camera pan
func pan_camera(dir: Global.Direction) -> void:
	target_offset = _create_vec(dir)
	
	_start_pan_transition()


func _start_pan_transition() -> void:
	change_state(State.PAN_TRANSITION)
	
	transition_timer = TRANSITION_TIME


func _create_vec(dir: Global.Direction) -> Vector2:
	var v: Vector2 = Vector2.ZERO
	pan_direction = dir
	
	match dir:
		Global.Direction.NORTH:
			v = Vector2(0, -stats.y_pan_target)
		Global.Direction.SOUTH:
			v = Vector2(0, stats.y_pan_target)
		Global.Direction.WEST:
			v = Vector2(-stats.x_pan_target, 0)
		Global.Direction.EAST:
			v = Vector2(stats.x_pan_target, 0)
	
	return v


func _handle_pan_transition(delta:float) -> void:
	if transition_timer <= 0:
		push_warning("Lo stato della camera non dovrebbe essere State.PAN_TRANSITION")
		return
	
	var prog_vector: Vector2 = _sample_pan_curve()
	
	offset.x = move_toward(offset.x, target_offset.x, prog_vector.x*delta)
	offset.y = move_toward(offset.y, target_offset.y, prog_vector.y*delta)
	
	if offset == target_offset:
		_end_pan_transition()


func _sample_pan_curve() -> Vector2:
	var t: float = clampf(transition_timer/TRANSITION_TIME, 0, 1)
	
	var progress: float = pan_curve.sample(t)
	
	match pan_direction:
		Global.Direction.NORTH, Global.Direction.SOUTH:
			return Vector2(0, progress*MAX_SPEED_Y)
		Global.Direction.WEST, Global.Direction.EAST:
			return Vector2(progress*MAX_SPEED_X, 0)
		_:
			return _get_return_vel(progress) #L'OFFSET DEVE TORNARE VERSO IL PUNTO 0 DEL PLAYER
	

func _end_pan_transition()->void:
	if abs(offset.x) < 0.0 and abs(offset.y) < 0.0:
		offset = DEF_OFFSET
		change_state(State.DEFAULT)
	else: 
		change_state(State.PAN)

func _get_return_vel(progress: float) -> Vector2:
	if abs(offset.x) >0:
		return Vector2(progress*MAX_SPEED_X, 0)
	else:
		return Vector2(0, progress*MAX_SPEED_Y)
#endregion


func change_state(new_state: State) -> void:
	if curr_cam_state != new_state:
		curr_cam_state = new_state
