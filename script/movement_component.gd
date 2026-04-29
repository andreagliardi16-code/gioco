#Il nodo si occupa di raccogliere tutte le istanze di movimento e
#di unirle, traducendole in un vettore normalizzato da passare al 
#nodo genitore.
#Occorre un movimento orizzontale che tenga conto di direzione
#(passata dall'input), dell'attrito e dell'inerzia. La formula
#dovrebbe essere qualcosa simile a:
#velocity.x = move_toward(velocity, MAX_SPEED*direction, acceleration)
#in cui la direzione dipende dall'input, MAX_SPEED è la costante di 
#velocità massima e acceleration un numero che dipende dalla 
#superficie su cui si trova il player e il tempo in cui dovrebbe
#raggiungere la sua velocità massima.
#A questo si dovrebbe aggiungere la gestione del movimento verticale 
#(in collegamento con gravity_component), la gestione dello stop e dei
#movimenti speciali.

class_name MovementComponent

extends Node2D

const JUMP_CUT_TIME: float = 0.15
const MIN_JUMP_TIME: float = 0.1
const MAX_JUMP_TIME: float = 0.6
const MAX_SPEED_CHANGE: int = 1000
const DEF_DASH_DIRECTION: int = 1 #destra
const VECTOR_X: String = "x"
const VECTOR_Y: String = "y"

signal energy_spended(action: String) #la stringa deve corrispondere alla stringa con cui l'azione è salvata nel dizionario PowerUpData

@export var pogo_scene: PackedScene

var parent: Player
var gravity: GravityComponent
var parent_stats: PlayerStats
var pogo: Pogo = null

var velocity: Vector2= Vector2(0,0)
var friction: float = 1.0
var acceleration: float = 0.0
var deceleration: float = 0.0
var velocity_y_mod: float = 0.0  #accumula gli "impulsi" di cambio velocità
var velocity_x_mod: float = 0.0  #accumula gli "impulsi" di cambio velocità
var direction: int = 0  #determina se il giocatore compie movimento orizzontale. Quando è fermo torna a 0 
var last_direction: int = 0  #determina l'ultima direzione in cui si è girato il player, anche se è fermo
var dash_direction: int = DEF_DASH_DIRECTION
var pogo_direction: Global.Direction = Global.Direction.SOUTH

#region timer var
var jump_cut_timer: float = 0.0
var min_jump_timer: float = 0.0
var coyote_timer: float = 0.0
var max_jump_timer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var pogo_impulse_timer: float = 0.0
#endregion

#region bool var
var is_jumping: bool = false  #forse rindondante con stati
var in_min_jump: bool = false
var wants_end_jump: bool = false
var is_jump_held: bool = false
var in_coyote_time: bool = false
var in_dash_cooldown: bool = false
var had_dash_jumped: bool = false
var side_pogo: bool = false
var is_fading_pogo: bool = false
var time_frozen: bool = false   #serve per freeze del movimento senza rompere gli stati
#endregion

#region setup e _process
func setup(stats: Stats, gravity_comp: GravityComponent, owner_node: Node2D):
	if stats == null or owner_node == null:
		print("errore in setup gravity")
	parent_stats = stats
	parent = owner_node
	gravity = gravity_comp


func _physics_process(delta: float) -> void:
	_calc_friction()
	_handle_timers(delta)
	if is_fading_pogo:
		_handle_pogo_fade(delta)
	if parent.curr_player_state == Player.PlayerStates.JUMP and not is_jump_held:
		_cut_jump()
#endregion

#region timer
func _handle_timers(delta: float) -> void:
	if jump_cut_timer > 0:
		jump_cut_timer -= delta
		if jump_cut_timer <= 0:
			jump_cut_timer = 0.0
			_end_jump()
	if min_jump_timer > 0:
		min_jump_timer -= delta
		if min_jump_timer <= 0:
			in_min_jump = false
			min_jump_timer = 0.0
			if wants_end_jump: _cut_jump()
	if max_jump_timer > 0:
		max_jump_timer -= delta
		if max_jump_timer <= 0:
			_end_jump()
	if coyote_timer > 0:
		coyote_timer -= delta
		if coyote_timer <= 0:
			coyote_timer = 0.0
			in_coyote_time = false
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			_end_dash()
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			in_dash_cooldown = false
	if pogo_impulse_timer > 0:
		pogo_impulse_timer -= delta
		if pogo_impulse_timer <= 0:
			_call_pogo_fade()
#endregion

#region move
func _move_x(delta: float) -> void:  ##DA AGGIUSTARE
	if parent.curr_player_state != Player.PlayerStates.DASH and parent.curr_player_state != Player.PlayerStates.POGO:  #implementare controlli
		velocity.x = _walk(delta)
		print("velocity camminata: ", velocity.x)
	
	velocity.x += velocity_x_mod
	velocity_x_mod = 0.0

#applica gravità quando necessario, forze di salto e altre
#modifiche alla velocità verticale
func _move_y(delta: float) -> void:
	# modifica velocity.y applicando la gravità
	apply_gravity(delta)
	
	velocity.y += velocity_y_mod
	#print("velocity_y_mod: ", velocity_y_mod)
	#print("velocity.y: ", velocity.y)
	velocity_y_mod = 0.0

#raccoglie i calcoli di move_x e move_y e li unisce in velocity, 
#ritornando il vettore completo e aggregato, da passare poi a 
#move_and_slide() del player
func move(delta: float) -> void:
	_move_x(delta)
	_move_y(delta)
	parent.apply_movement(velocity)
#endregion

#region gravity
func apply_gravity(delta: float) -> void:
	if parent.curr_physic_state == Player.PhysicsStates.GROUND or parent.curr_player_state == Player.PlayerStates.DASH:
		velocity.y = 0.0
		return
	
	var g = gravity.get_gravity()
	vel_y_request(g * delta)
#endregion

#region direction
func change_direction(n: int) -> void:
	direction = clampi(n, -1, 1)

func _change_last_direction():
	if direction == 0:
		return
	last_direction = direction

func changing_direction() -> bool:  #serve per quando il giocatore cambia direzione e deve prima decelerare e poi acceleraree
	if direction == last_direction or last_direction == 0:
		#print("returning false")
		return false
	elif abs(velocity.x) > 10:
		#print("returning true")
		return true
	return false
#endregion

#region walk
func _walk(delta: float) -> float:
	var new_speed_x: float = velocity.x #velocità della camminata in un frame
	var acc: float = 0
	if direction == 0 or changing_direction():
		print("pfrz")
		acc = apply_sign(new_speed_x, delta*parent_stats.deceleration*friction)
		new_speed_x = move_toward(new_speed_x, 0, acc)
		return new_speed_x
	
	var target_speed: int = parent_stats.max_speed * direction
	acc = apply_sign(new_speed_x, delta*parent_stats.acceleration*friction)
	new_speed_x = move_toward(new_speed_x, target_speed, acc)
	if sign(new_speed_x) == sign(direction):
		_change_last_direction()
	
	return new_speed_x


func apply_sign(new_speed_x: float, a: float) -> float:
	if not abs(new_speed_x) > parent_stats.max_speed:
		return a
	a *= 2     #serve per tornare più velocemente nel range della velocità normale
	return a
#endregion

#region jump
func call_jump() -> void:
	parent.add_to_queue(Player.PlayerActions.JUMP)

func jump() -> void:
	#la funzione si occupa solo di dare la velocità iniziale del salto
	#e di cambiare gravità, stati e timer. La forma del salto verrà 
	#data dallo scalare frame-by-frame la gravità nel move_y
	#il controllo sul poter saltare va fatto nella coda
	#parent.change_player_state(Player.PlayerStates.JUMP)
	emit_signal("energy_spended", "jump")
	
	min_jump_timer = MIN_JUMP_TIME
	max_jump_timer = MAX_JUMP_TIME
	is_jumping = true
	
	_fast_stop([VECTOR_Y])
	vel_y_request(parent_stats.jump_force)

func _cut_jump() -> void:
	if in_min_jump:
		wants_end_jump = true
	jump_cut_timer = JUMP_CUT_TIME
	

func _set_gravity_as_fall() -> void:
	pass
	#parent.change_player_state(Player.PlayerStates.FALL)

func _end_jump() -> void:
	is_jumping = false
	wants_end_jump = false
	max_jump_timer = 0.0
	jump_cut_timer = 0.0
	_set_gravity_as_fall()

func _on_input_component_jump_input_changed(state: bool) -> void:
	if state == true:
		is_jump_held = true
	else:
		is_jump_held = false
#endregion

#region dash 
func call_dash() -> void:
	parent.add_to_queue(Player.PlayerActions.DASH)

func dash() -> void:
	_fast_stop([VECTOR_X, VECTOR_Y])
	
	emit_signal("energy_spended", "dash")
	dash_direction = _get_dash_direction()
	vel_x_request(parent_stats.dash_speed_amt*dash_direction)
	
	dash_timer = parent_stats.dash_time
	dash_cooldown_timer = parent_stats.dash_cooldown
	in_dash_cooldown = true
	
	if parent.curr_physic_state != Player.PhysicsStates.GROUND:
		change_dash_jump_bool(true)

func _get_dash_direction() -> int:
	if direction != 0:
		return direction
	if last_direction != 0:
		return last_direction
	return DEF_DASH_DIRECTION

func _end_dash() -> void:
	dash_timer = 0.0
	vel_x_request(parent_stats.dash_cut*dash_direction)

func change_dash_jump_bool(arg: bool) -> void:
	had_dash_jumped = arg
#endregion

#region pogo
func call_pogo(dir: Global.Direction):
	parent.add_to_queue(Player.PlayerActions.POGO)
	pogo_direction = dir


func do_pogo() -> void:
	emit_signal("energy_spended", "pogo")
	pogo.pogo_jump(pogo_direction)


func _on_pogo_started() -> void:
	print("inizio pogo")
	var vector: Vector2 = _create_pogo_impulse()
	
	_start_pogo_timer()
	
	_fast_stop([VECTOR_X, VECTOR_Y])
	vel_x_request(vector.x)
	vel_y_request(vector.y)



func _start_pogo_timer() -> void:
	pogo_impulse_timer = pogo.IMPULSE_DURATION


func _create_pogo_impulse() -> Vector2:
	match pogo_direction:
		Global.Direction.EAST:
			side_pogo = true
			return Vector2(-parent_stats.side_force, parent_stats.vertical_force)
		Global.Direction.SOUTH:
			side_pogo = false
			return Vector2(0.0, parent_stats.vertical_force)
		Global.Direction.WEST:
			side_pogo = true
			return Vector2(parent_stats.side_force, parent_stats.vertical_force)
		_: 
			_fast_stop([VECTOR_X, VECTOR_Y])
			side_pogo = false
			pogo.end_pogo()
			return Vector2.ZERO


func _call_pogo_fade() -> void:
	pogo.fade_pogo_jump()
	print("inizio pogo fade")


func _handle_pogo_fade(delta: float) -> void:
	var n: float 
	n = -pogo.sample_fade(delta)
	vel_x_request(n)


func _on_pogo_fade_started() -> void:
	is_fading_pogo = true


func _on_pogo_ended() -> void:
	is_fading_pogo = false
	print("fine pogo")
#endregion

#region misc
func _calc_friction() -> void:
	var n
	n = parent.get_friction()
	if n == null:
		friction = 1.0
	else:
		friction = n

func _fast_stop(axis: Array[String]) -> void: 
	var a: int = axis.size()
	if a > 2:
		push_warning("argomenti passati a _fast_stop non validi: ", axis)
		return
	
	for i in range(a):
		if axis[i] == "x":
			velocity.x = 0.0
		if axis[i] == "y":
			velocity.y = 0.0

func hit_ceiling() -> void:  #controllare bool e edge cases
	velocity.y = 0
	is_jumping = false
	wants_end_jump = false
#endregion

#region velocity_mod_requests
func vel_y_request(new_request: float) -> void: 
	#serve per unificare i cambiamenti operati sull'asse y della velocità
	velocity_y_mod = clamp(velocity_y_mod + new_request, -MAX_SPEED_CHANGE, MAX_SPEED_CHANGE)

func vel_x_request(new_request: float) -> void:
	velocity_x_mod += new_request
#endregion

#region add_powerups
func add_pogo() -> void:
	if is_instance_valid(pogo):
		push_warning("Pogo seems to be already instanced: ", pogo)
		return
	
	pogo = pogo_scene.instantiate()
	add_child(pogo)
	
	pogo.pogo_started.connect(_on_pogo_started)
	pogo.pogo_fade_started.connect(_on_pogo_fade_started)
	pogo.pogo_ended.connect(_on_pogo_ended)
#endregion
