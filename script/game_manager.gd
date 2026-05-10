extends Node
class_name GameManager

enum GameState {GAME, PAUSE, TRANSITION}
var curr_game_state: GameState = GameState.TRANSITION

@export var main_menu: PackedScene
@export var level_map: LevelMap = null

@onready var player: Player = $CharacterBody2D
@onready var level_container: Node = $LevelContainer
@onready var ui: CanvasLayer = $UI

var current_level: Level = null
var death_timer: Timer = null

func _ready() -> void:
	start_game()
	level_map.reload_level_db()
	TimeManager.switch_timer(true)

#region cambio livelli
func change_level(scene_id: StringName) -> void:
	var scene_path: String = find_level(scene_id)
	
	if scene_path.is_empty():
		return
	
	load_level(scene_path)
	
	await get_tree().process_frame
	
	RespawnManager.build_spawn_map(current_level)
	
	player.spawn()
	change_game_state(GameState.GAME)


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
	var menu = main_menu.instantiate()
	ui.add_child(menu)
	menu.setup(self)


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
