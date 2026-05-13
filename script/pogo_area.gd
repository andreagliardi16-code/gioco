# rileva collisione con oggetti pogabili, ha un timer che determina per quanto
# la collisione rimane attiva e ritorna se una collisione avviene nel tempo
# stabilito

extends Area2D

class_name PogoArea


const TIME: float = 0.15

var active: bool = false
var active_timer: float = 0.0

@onready var collision = $CollisionShape2D


func _ready() -> void:
	monitoring = false
	monitorable = false


func _process(delta: float) -> void:
	_handle_timers(delta)


func _handle_timers(delta: float) -> void:
	if active_timer > 0:
		active_timer -= delta
		if active_timer <= 0:
			end_detection()


func start_detection(vec: Vector2) -> void:
	position = vec
	active = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	active_timer = TIME


func end_detection() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	active = false
	position = Vector2.ZERO
