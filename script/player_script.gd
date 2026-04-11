class_name Player

extends CharacterBody2D

enum PhysicsStates {DEFAULT, GROUND, AIR}
var curr_physic_state: PhysicsStates = PhysicsStates.DEFAULT
enum PlayerStates {IDLE, SLIDE, JUMP, FALL, DASH}
var curr_player_state: PlayerStates = PlayerStates.IDLE
enum PlayerActions {JUMP, DASH} #tutte le azioni che si possono bufferare

@export var stats: PlayerStats
@export var powers: PowerUpData
@onready var hitbox = $hitbox
@onready var base: BaseArea = $BaseArea
@onready var gravity: GravityComponent = $GravityComponent
@onready var input: InputComponent = $InputComponent
@onready var movement: MovementComponent = $MovementComponent
@onready var queue: QueueComponent = $QueueComponent
@onready var camera: CameraComponent = $CameraComponent

var friction: float = 0.0

var can_walk: bool = true

#region _ready, _process e setup
func _ready() -> void:
	link_components()

func link_components() -> void:
	gravity.setup(stats, self)
	input.setup(movement, self)
	movement.setup(stats, gravity, self)
	base.setup(self)
	queue.setup(movement, self)
	camera.setup(stats, self)

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
	if movement.dash_timer > 0.0:
		curr_player_state = PlayerStates.DASH
		return
	if movement.is_jumping:
		curr_player_state = PlayerStates.JUMP
		return
	if velocity.y > 0:
		curr_player_state = PlayerStates.FALL
		return
	if velocity.x > 0:
		curr_player_state = PlayerStates.SLIDE
		return
	else:
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
	print("inizio coyote time")
	movement.coyote_timer = stats.coyote_time
	movement.in_coyote_time = true
#endregion

#region controllo sulle azioni
func can_jump() -> bool:  #IMPLEMENTARE BENE (controllo su stati (non su variabili), coyote time ecc...)
	if (movement.in_coyote_time or curr_physic_state == PhysicsStates.GROUND) and curr_player_state != PlayerStates.JUMP:
		return true
	
	return false

func can_dash() -> bool:  #IMPLEMENTARE (controllo su stati)
	if movement.in_dash_cooldown or movement.had_dash_jumped:
		return false
	
	return true
#endregion

func add_to_queue(action: PlayerActions) -> void:
	queue.add_to_queue(action)

func input_active(id: String) -> bool:
	if not powers.power_ups[id]:
		print("Errore nell'assegnazione della stringa di input: ", id)
		return false
	
	return powers.power_ups[id]["active"]
