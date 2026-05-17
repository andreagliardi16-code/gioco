#La componente riceve tutti gli input e li smista alla coda, che si
#occupa di ordinarli e farli eseguire. 
#La componente deve sempre essere figlia del nodo principale a cui si
#riferisce.

class_name InputComponent

extends Node

const VERT_ANGLE_THRESHOLD: float = 0.65
const LOOK_VERT_THRESHOLD: float = 0.8

signal jump_input_changed(state: bool)  #dice a moovement quando viene premuto e rilasciato il salto
signal look_input_changed(dir: Global.Direction)

var parent: CharacterBody2D
var movement: MovementComponent 
var queue: QueueComponent

var last_direction: Global.Direction = Global.Direction.NULL
var look_direction: Global.Direction = Global.Direction.NULL
var _last_pan_input: Vector2 = Vector2.ZERO

#region ready, process e setup
func _ready() -> void:
	self.set_meta("ID", &"InputComponent")

func _physics_process(_delta: float) -> void:
	_check_inputs()
	_look_around()
	

func setup(mov_node: MovementComponent, owner_node: Node) -> void:
	parent = owner_node
	movement = mov_node
#endregion

#region input
func _check_inputs() -> void:
	#if not parent.can_move(): return
	if Input.is_action_just_pressed("dash"):
		if not parent.input_active("dash"):
			return
		movement.call_dash()
	
	if Input.is_action_just_pressed("pogo"):
		if not parent.input_active("pogo"):
			return
		var d = _get_direction()
		if not d == Global.Direction.NULL:
			movement.call_pogo(d)
	
	if Input.is_action_just_pressed("jump"):
		if not parent.input_active("jump"):
			return
		movement.call_jump()
		emit_signal("jump_input_changed", true)
	if Input.is_action_just_released("jump"):
		emit_signal("jump_input_changed", false)
		#movement.end_jump()
	
	if Input.is_action_pressed("move_right"):
		last_direction = Global.Direction.EAST
		movement.change_direction(1) 
	elif Input.is_action_just_released("move_right"):
		movement.change_direction(0) 
	if Input.is_action_pressed("move_left"):
		last_direction = Global.Direction.WEST
		movement.change_direction(-1) 
	elif Input.is_action_just_released("move_left"):
		movement.change_direction(0) 
#endregion


func _get_direction() -> Global.Direction:    #return null se non è premuta direzione, altrimenti global.direction
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector.length() < 0.2 :
		return last_direction
	
	var dir: Vector2 = input_vector.normalized()
	
	return _translate_vec_to_dir(dir, VERT_ANGLE_THRESHOLD)


#region look around
func _look_around() -> void:
	var vec: Vector2 = _get_look_vector()
	
	#if vec.length() < 0.2 and _last_pan_input.length() < 0.2:
		#return
	
	_last_pan_input = vec
	
	var dir: Global.Direction = _translate_vec_to_dir(vec.normalized(), LOOK_VERT_THRESHOLD)
	
	if dir == look_direction: return
	else:
		look_direction = dir
		look_input_changed.emit(look_direction)


func _get_look_vector() -> Vector2:
	var v: Vector2 = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	return v
#endregion


func _translate_vec_to_dir(v: Vector2, vertical_threshold: float) -> Global.Direction:	
	if v.dot(Vector2.DOWN) > vertical_threshold:
		return Global.Direction.SOUTH
	
	if v.dot(Vector2.UP) > vertical_threshold:
		return Global.Direction.NORTH
	
	if v.x > 0:
		return Global.Direction.EAST
	
	if v.x < 0: 
		return Global.Direction.WEST
	
	return Global.Direction.NULL
