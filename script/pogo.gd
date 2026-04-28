# usa gli stati per controllare il pogo. Il movement lo istanzia nel player 
# quando si sblocca il power-up. Movement deve avere una reference a pogo,
# non viceversa.

extends Node2D

class_name Pogo


const IMPULSE_DURATION: float = 0.125
const FADE_DURATION: float = 0.3

enum State {IMPULSE, FADE, OFF}  #determina il comportamento con altri power-up  

signal pogo_started(force: Vector2)
signal pogo_fade_started()
signal pogo_ended()

@export var pogo_fade_curve: Curve 

var curr_pogo_state: State = State.OFF
var pogo_direction: Global.Direction
var fade_timer: float = 0.0

@onready var coll_area: PogoArea = $PogoArea


#region controllo stati
func pogo_jump(dir: Global.Direction) -> void:
	_set_collision(dir)


func _start_pogo_jump() -> void:
	curr_pogo_state = State.IMPULSE
	
	emit_signal("pogo_started", pogo_direction)  #il movement si occupa di applicarlo


func fade_pogo_jump() -> void:
	curr_pogo_state = State.FADE
	fade_timer = 0.0
	
	emit_signal("pogo_fade_started")


func sample_fade(delta: float) -> float:
	if not curr_pogo_state == State.OFF:
		push_warning("sample_fadde() chiamato in maniera impropria")
		return 0
	
	var speed: float = 0.0
	var x: float = clampf(fade_timer/FADE_DURATION, 0.0, 1.0)
	
	if x >= 1.0:
		end_pogo()
	
	speed = pogo_fade_curve.sample(x)
	fade_timer = clampf(fade_timer+delta, 0.0, FADE_DURATION)
	#speed va moltiplicata per la velocità massima del dash
	
	return speed


func end_pogo() -> void:
	curr_pogo_state = State.OFF
	emit_signal("pogo_ended")
#endregion

#region detection collisione
func _set_collision(dir: Global.Direction) -> void:
	pogo_direction = dir
	var vector = _create_vector()
	
	if vector == Vector2.ZERO:
		return 
	
	coll_area.start_detection(vector)


func _create_vector() -> Vector2:
	match pogo_direction:
		Global.Direction.EAST:
			return Vector2(50.0, 0.0)
		Global.Direction.SOUTH:
			return Vector2(0.0, 65.0)
		Global.Direction.WEST:
			return Vector2(-50.0, 0.0)
		Global.Direction.NORTH:
			return Vector2(0.0, -65.0)
		_:
			push_error("Errore nel passaggio della direzione: ", pogo_direction)
			return Vector2.ZERO
#endregion


func _on_pogo_area_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pogoable_areas"):
		return
	
	coll_area.end_detection()
	_start_pogo_jump()


func is_blocking_movement() -> bool:
	return curr_pogo_state == State.IMPULSE
