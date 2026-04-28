class_name Player

extends CharacterBody2D

signal components_linked
signal had_died

enum PhysicsStates {DEFAULT, GROUND, AIR}
var curr_physic_state: PhysicsStates = PhysicsStates.DEFAULT
enum PlayerStates {IDLE, SLIDE, JUMP, FALL, DASH, POGO, DEAD}
var curr_player_state: PlayerStates = PlayerStates.IDLE
enum PlayerActions {JUMP, DASH, POGO} #tutte le azioni che si possono bufferare

@export var stats: PlayerStats
@export var powers: PowerUpData

@onready var hitbox = $hitbox
@onready var base: BaseArea = $BaseArea
@onready var gravity: GravityComponent = $GravityComponent
@onready var input: InputComponent = $InputComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var queue: QueueComponent = $QueueComponent
@onready var camera: CameraComponent = $CameraComponent
@onready var stats_manager: StatsComponent = $StatsComponent
@onready var hud: Hud = $HUD
@onready var respawn: RespawnComponent = $RespawnComponent

var friction: float = 0.0

var can_walk: bool = true

#region _ready, _process e setup
func _ready() -> void:
	link_components()
	check_power_ups()
	#da spostare in altro script


func check_power_ups() -> void:
	if powers.power_ups["pogo"]["active"]:
		_unlock_powerup(PlayerActions.POGO)
	#aggiungere tutti gli altri man mano che si implementano


func link_components() -> void:
	gravity.setup(stats, self)
	input.setup(movement, self)
	movement.setup(stats, gravity, self)
	base.setup(self)
	queue.setup(movement, self)
	camera.setup(stats, self)
	stats_manager.setup(stats, powers, self)
	hud.setup(stats, stats_manager)
	emit_signal("components_linked")

func activate(switch:bool) -> void:
	visible = switch
	if switch:
		process_mode = Node.PROCESS_MODE_INHERIT
		return
	process_mode = Node.PROCESS_MODE_DISABLED

func _physics_process(delta: float) -> void:
	check_physics_state()
	check_player_state()
	gravity.update_gravity()
	movement.move(delta)
	move_and_slide()
	if is_on_ceiling():
		velocity.y = 0
		movement.hit_ceiling()
#endregion

#region state
func check_physics_state() -> void:
	if base.on_floor:
		curr_physic_state = PhysicsStates.GROUND
		movement.change_dash_jump_bool(false)
	else:
		curr_physic_state = PhysicsStates.AIR

func check_player_state() -> void:
	if respawn.death_timer and respawn.death_timer.time_left > 0:
		curr_player_state = PlayerStates.DEAD
		if movement.side_pogo: _set_can_walk(false)
		return
	elif movement.pogo_impulse_timer > 0.0:
		curr_player_state = PlayerStates.POGO
		_set_can_walk(false)
	elif movement.dash_timer > 0.0:
		curr_player_state = PlayerStates.DASH
		_set_can_walk(false)
		return
	elif movement.is_jumping:
		_set_can_walk(true)
		curr_player_state = PlayerStates.JUMP
		return
	elif velocity.y > 0:
		_set_can_walk(true)
		curr_player_state = PlayerStates.FALL
		return
	elif velocity.x > 0:
		_set_can_walk(true)
		curr_player_state = PlayerStates.SLIDE
		return
	else:
		_set_can_walk(true)
		curr_player_state = PlayerStates.IDLE
		return 

#func cange_player_state(new_state: ) -> void:
#endregion

#region movement
func get_friction() -> float:
	return base.change_friction()

func apply_movement(vel: Vector2) -> void:
	velocity = vel

func start_coyote_time():
	movement.coyote_timer = stats.coyote_time
	movement.in_coyote_time = true
#endregion

#region controllo sulle azioni
func can_jump() -> bool:  #IMPLEMENTARE BENE (controllo su stati (non su variabili), coyote time ecc...)
	if (movement.in_coyote_time or curr_physic_state == PhysicsStates.GROUND) and curr_player_state != PlayerStates.JUMP:
		return true
	
	return false


func can_dash() -> bool:  #IMPLEMENTARE (controllo su stati)
	if movement.in_dash_cooldown or movement.had_dash_jumped or not check_power("dash"):
		return false
	
	return true


func can_pogo() -> bool:
	if is_on_floor():
		return false
	
	return true

func _set_can_walk(arg: bool) -> void:
	can_walk = arg
#endregion

#region power-up
func input_active(id: String) -> bool:
	if not powers.power_ups[id]:
		print("Errore nell'assegnazione della stringa di input: ", id)
		return false
	
	return powers.power_ups[id]["active"]

func check_power(id: String) -> bool:  #con poca energia l'azione si può svolgere fino a che non ci sia almeno metà del suo costo per rendere meno punitivo il sistema 
	var n: float = stats_manager.get_energy()
	
	if n > powers.power_ups[id]["cost"]/2:
		return true
	
	return false
#endregion

#region spawn e respawn
func die() -> void:
	emit_signal("had_died")


func spawn() -> void:   #da cambiare
	position = respawn.respawn()
	print("spawno in posizione: ", position)
#endregion


func _unlock_powerup(powerup: PlayerActions) -> void:
	match powerup:
		PlayerActions.POGO:
			movement.add_pogo()


func add_to_queue(action: PlayerActions) -> void:
	queue.add_to_queue(action)
