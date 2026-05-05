@tool

extends StaticPlatform
class_name MovingPlatform


const MAX_RANGE: int = 1000

enum State {ON, OFF}


@export var curve: Curve = null
@export var target_position: Vector2 = Vector2.ZERO:
	set(value):
		target_position = value
		update_configuration_warnings()
@export var def_speed: float = 0.0
@export var pause_time: float = 0.0

@onready var target_anchor: Marker2D = $Marker2D

var curr_state: State = State.OFF
var mov_timer: float = 0.0


func _ready() -> void:
	_set_anchor_position()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	else:
		_move(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var msg: PackedStringArray 
	
	if target_position == Vector2.ZERO:
		msg.append("Inserire una posizione target")
	
	return msg


func _set_anchor_position() -> void:
	if target_position != Vector2.ZERO and _in_range():
		target_anchor.position = target_position
		return
	
	push_warning("posizione dell'anchor non valida per la piattaforma: ", self)


func _in_range() -> bool:
	if abs(target_position.x) > MAX_RANGE or abs(target_position.y) > MAX_RANGE:
		return false
	
	return true

func _move(delta: float) -> void:
	# creare una funzione che calcola la posizione in base al tempo globale
	# o il tempo in una stanza. Fare poi in modo che se c'è una curva 
	# dall'editor si leghi la posizione al tempo usando la curva, altrimenti
	# che la velocità sia costante.
	return
