extends Node
class_name GameManager


const SPAWN_FILE_PATH: String = "user://spawn_data"


enum GameState {GAME, PAUSE, TRANSITION}
var curr_game_state: GameState = GameState.TRANSITION


@export var main_menu: PackedScene
@export var level_map: LevelMap = null

@onready var player: Player = $CharacterBody2D
@onready var level_container: Node = $LevelContainer
@onready var ui: CanvasLayer = $UI

var current_level: Level = null
var death_timer: Timer = null
var using_gate: bool = false


func _ready() -> void:
	Global.set_game_manager(self)
	
	start_game()
	level_map.reload_level_db()
	TimeManager.switch_timer(true)


#region cambio livelli
func change_level(scene_id: StringName, gate_id: StringName = &"") -> void:
	print("CAMBIO LIVELLO")
	
	var scene_path: String = find_level(scene_id)
	
	if scene_path.is_empty():
		return
	
	call_deferred("load_level", scene_path)
	
	await get_tree().process_frame
	
	RespawnManager.build_spawn_map(current_level)
	
	await get_tree().process_frame
	
	if using_gate:
		var pos: Vector2 = _get_gate_pos(gate_id)
		player.update_spawn(pos)
	
	player.spawn()
	
	change_game_state(GameState.GAME)
	using_gate = false


func load_level(scene_path: String) -> void:
	if current_level:
		current_level.queue_free()
	
	var scene: PackedScene = load(scene_path)
	current_level = scene.instantiate()
	level_container.add_child(current_level)


func find_level(id: StringName) -> String:
	var level_data: LevelData = level_map.levels.get(id)
	
	if level_data == null:
		push_error("Id non corretto, scena non trovata, id: ", id)
		return ""
	
	return level_data.scene_path
#endregion

#region stati
func change_game_state(new_state: GameState) -> void:
	if new_state == curr_game_state: 
		return
	
	curr_game_state = new_state
	change_activity()
#endregion

#region activity
func change_activity() -> void:
	match curr_game_state:
		GameState.GAME:
			ui.activate(false)
			level_container.activate(true)
			player.activate(true)
		GameState.PAUSE:
			ui.activate(true)
			level_container.activate(false)
			player.activate(false)
		GameState.TRANSITION:
			ui.activate(true)
			level_container.activate(false)
			player.activate(false)
#endregion


func start_game() -> void:
	change_game_state(GameState.PAUSE)
	
	var err = _check_config_and_load()
	if err != Global.Outcome.OK:
		push_error("Impossibile caricare il file con i dati di spawn per iniziare la partita")
		get_tree().quit()
	
	var menu = main_menu.instantiate()
	ui.add_child(menu)
	menu.setup(self)


#region death
func _on_character_body_2d_had_died() -> void:
	handle_death()


func handle_death() -> void:
	player.spawn()
	change_game_state(GameState.TRANSITION)
	
	death_timer = Timer.new()
	death_timer.wait_time = 0.5
	death_timer.one_shot = true
	
	death_timer.timeout.connect(_on_timer_timeout)
	
	add_child(death_timer)
	death_timer.start()


func _on_timer_timeout() -> void:
	death_timer.queue_free()
	change_game_state(GameState.GAME)
#endregion


func _on_level_container_child_entered_tree(node: Node) -> void:
	if node is not Level:
		return
	
	node.level_exited.connect(_on_level_exited)


func _on_level_exited(level_id: StringName, gate_id: StringName) -> void:
	if not level_map.has_gate(level_id, gate_id):
		return
	
	using_gate = true
	change_level(level_id, gate_id)


func _get_gate_pos(gate_id: StringName) -> Vector2:
	var v: Vector2 = current_level.get_gate_pos(gate_id)
	
	return v


#region spawn data ConfigFile
func _check_config_and_load() -> Global.Outcome:
	var config: ConfigFile = ConfigFile.new()
	
	#carico il file dal computer dell'utente
	var err = config.load(SPAWN_FILE_PATH)
	
	# se il file non esiste (o si è corrotto) si crea uno nuovo con dati di inizio partita
	var c: int = 0
	while err != OK:
		c += 1
		_build_spawn_file(config)
		err = config.load(SPAWN_FILE_PATH)
		
		if c > 3:
			return Global.Outcome.FAIL
	
	#se il file esiste già lo leggo e "scrivo i distribuisco" i dati dove servono
	var spawn_level: StringName = config.get_value("spawn_data", "spawn_level")
	var spawn_id: StringName = config.get_value("spawn_data", "spawn_id")
	
	player.respawn.update_pos(spawn_id)
	Global.set_spawn_level(spawn_level)
	
	return Global.Outcome.OK


func _build_spawn_file(config: ConfigFile) -> void:
	#aggiungo i valori di base al file
	config.set_value("spawn_data", "spawn_level", &"test_level")
	config.set_value("spawn_data", "spawn_id", &"test_level")
	
	#salvo il file su disco
	config.save(SPAWN_FILE_PATH)


func change_spawn_data(spawn_id: StringName, spawn_level: StringName) -> Global.Outcome:
	var config: ConfigFile = ConfigFile.new()
	
	var err = config.load(SPAWN_FILE_PATH)
	if err != OK:
		push_error("Impossibile accedere ai file con dati dello spawn")
		return Global.Outcome.FAIL
	
	# modifico i dati
	config.set_value("spawn_data", "spawn_level", spawn_level)
	config.set_value("spawn_data", "spawn_id", spawn_id)
	
	# salvo sul comupter dell'utente
	config.save(SPAWN_FILE_PATH)  # si potrebbe aggiungere controllo sulla sovrascrittura
	return Global.Outcome.OK
#endregion
