#componente che si occupa di gestire le code di input con priorità e 
#tempi di permanenza. Ogni item in coda è l'istanza di una risorsa 
#QueueItem identificabile da un id

class_name QueueComponent

extends Node

const MAX_ARRAY_SIZE: int = 10
const SPAM_THRESHOLD: float = 0.2

var input_queue: Array = []  #coda di input
var parent: Player
var movement: MovementComponent

#region setup e process
func _physics_process(delta: float) -> void:
	_update_queue(delta)

func setup(movement_component: MovementComponent, parent_node: Player) -> void:
	parent = parent_node
	movement = movement_component
#endregion

#region aggiornamento coda
func _update_queue(delta: float) -> void:
	
	if input_queue.is_empty():
		return
	
	match input_queue[0].id:
		&"jump":
			if parent.can_jump():
				movement.jump()
				input_queue.remove_at(0)
		&"dash":
			if parent.can_dash():
				movement.dash()
				input_queue.remove_at(0)
		&"pogo":
			if parent.can_pogo():
				movement.do_pogo()
				input_queue.remove_at(0)
		&"error":
			print("errore nel passaggio di elementi in coda. Arg: ", input_queue[0].error_arg) 
			input_queue.remove_at(0)
	
	for i in range(input_queue.size() -1, -1, -1):
		input_queue[i].life -= delta
		if input_queue[i].life <= 0:
			input_queue.remove_at(i)

func add_to_queue(player_action: Player.PlayerActions) -> void:
	var new_item = create_queue_item(player_action)
	
	for i in range(input_queue.size()):
		if new_item.priority > input_queue[i].priority:
			_merge_inpus(i, new_item)
			var n = _check_array_size()
			if n == 0:
				return
			else:
				for j in range(n):
					input_queue.pop_back()
				return
	
	if input_queue.size() >= MAX_ARRAY_SIZE:
		return
	input_queue.append(new_item)
#endregion

#region item
func create_queue_item(player_action: Player.PlayerActions) -> QueueItem:
	match player_action:
		Player.PlayerActions.JUMP:
			return QueueJump.new()
		Player.PlayerActions.DASH:
			return QueueDash.new()
		Player.PlayerActions.POGO:
			return QueuePogo.new()
		_:
			return QueueError.new(player_action)
#endregion

#region controlli
func _check_array_size() -> int:
	if input_queue.size() <= MAX_ARRAY_SIZE: return 0
	else:
		return input_queue.size() - MAX_ARRAY_SIZE

func _merge_inpus(position: int, new_item: QueueItem) -> void:   #il giocatore potrebbe spammare un comando, per evitare che la coda si affolli, due input uguali vicini in coda (con t abbastanza vicino) vengono considerati come uno soloo
	if position == 0: #l'input non ha "simili"
		return
	
	var delta_time : float = new_item.life - input_queue[position-1].life
	if input_queue[position-1].id == new_item.id and delta_time < SPAM_THRESHOLD: #in questo caso i due input sono frutto di spam e si scarta il secondo
		return
	
	input_queue.insert(position, new_item)
#endregion
