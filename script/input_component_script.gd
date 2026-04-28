#La componente riceve tutti gli input e li smista alla coda, che si
#occupa di ordinarli e farli eseguire. 
#La componente deve sempre essere figlia del nodo principale a cui si
#riferisce.

class_name InputComponent

extends Node

const VERT_ANGLE_THERSHOLD: float = 0.65

signal jump_input_changed(state: bool)  #dice a moovement quando viene premuto e rilasciato il salto

var parent: CharacterBody2D
var movement: MovementComponent #forse non serve il collegamento diretto
var queue

var last_direction: Global.Direction = Global.Direction.NULL

func _ready() -> void:
	self.set_meta("ID", &"InputComponent")

func _physics_process(_delta: float) -> void:
	check_inputs()

func setup(mov_node: MovementComponent, owner_node: Node) -> void:
	parent = owner_node
	movement = mov_node

func check_inputs() -> void:
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

func _get_direction() -> Global.Direction:    #return null se non è premuta direzione, altrimenti global.direction
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "look_up", "look_down")
	
	if input_vector.length() < 0.2:
		return last_direction
	
	var dir: Vector2 = input_vector.normalized()
	
	if dir.dot(Vector2.DOWN) > VERT_ANGLE_THERSHOLD:
		return Global.Direction.SOUTH
	
	if dir.dot(Vector2.UP) > VERT_ANGLE_THERSHOLD:
		return Global.Direction.NORTH
	
	if dir.x > 0:
		return Global.Direction.EAST
	
	return Global.Direction.WEST
