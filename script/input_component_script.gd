#La componente riceve tutti gli input e li smista alla coda, che si
#occupa di ordinarli e farli eseguire. 
#La componente deve sempre essere figlia del nodo principale a cui si
#riferisce.

class_name InputComponent

extends Node

signal jump_input_changed(state: bool)  #dice a moovement quando viene premuto e rilasciato il salto

var parent: CharacterBody2D
var movement: MovementComponent #forse non serve il collegamento diretto
var queue

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
		movement.call_dash()
	if Input.is_action_just_pressed("jump"):
		movement.call_jump()
		emit_signal("jump_input_changed", true)
	if Input.is_action_just_released("jump"):
		emit_signal("jump_input_changed", false)
		#movement.end_jump()
	
	if Input.is_action_pressed("move_right"):
		movement.change_direction(1) 
	elif Input.is_action_just_released("move_right"):
		movement.change_direction(0) 
	if Input.is_action_pressed("move_left"):
		movement.change_direction(-1) 
	elif Input.is_action_just_released("move_left"):
		movement.change_direction(0) 
