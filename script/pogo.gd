# usa gli stati per controllare il pogo. Il movement lo istanzia nel player 
# quando si sblocca il power-up. Movement deve avere una reference a pogo,
# non viceversa.

extends Node2D

class_name Pogo

enum State {IMPULSE, FADE, OFF}  #determina il comportamento con altri power-up  
var curr_pogo_state: State = State.OFF

@onready var area: Area2D = $PogoArea


func pogo_jump(dir: Global.Direction) -> void:
	#creo collision_shape per controllare collisione in base alla direzione
	
	# se c'è collisione (o avviene in un tempo stabilito di pochi frame)
	# avvio la logica del pogo_jump
	
	# cambio stato a impulse, creo un vettore forza dipendente dalla
	# direzione in cui è avvenuta la collisione, lo ritorno in qualche
	# modo a movement e blocco altri movimenti
	
	# cambio stato a fade e scalo il modificatore di velocità lasciando
	# che gli altri movimenti influenzino il movimento totale
	
	# dopo una soglia di velocità ritorno in stato State.OFF
	pass


func _check_collision(dir: Global.Direction) -> bool:
	var vector = _create_vector(dir)
	if vector == Vector2.ZERO:
		return false
	
	
	return false


func _create_vector(dir: Global.Direction) -> Vector2:
	match dir:
		Global.Direction.EAST:
			return Vector2(40.0, 0.0)
		Global.Direction.SOUTH:
			return Vector2(0.0, 60.0)
		Global.Direction.WEST:
			return Vector2(-40.0, 0.0)
		Global.Direction.NORTH:
			return Vector2(0.0, -60.0)
		_:
			push_error("Errore nel passaggio della direzione: ", dir)
			return Vector2.ZERO
