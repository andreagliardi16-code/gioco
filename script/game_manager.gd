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

func _ready() -> void:
	start_game()

#region cambio livelli
func change_level(scene_id: StringName) -> void:
	print(scene_id)
	var scene = find_level(scene_id)
	load_level(scene)
	
	await get_tree().process_frame
	
	RespawnManager.build_spawn_map(current_level)
	
	player.spawn()
	change_game_state(GameState.GAME)


func load_level(scene: PackedScene) -> void:
	if current_level:
		current_level.queue_free()
	
	current_level = scene.instantiate()
	level_container.add_child(current_level)


func find_level(id: StringName) -> PackedScene:
	var a = level_map.levels.get(id)
	
	if a == null:
		push_error("Id non corretto, scena non trovata")
		return
	
	return a
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
			print("sgrodol")
			ui.activate(true)
			level_container.activate(false)
			player.activate(false)
		_:
			ui.activate(false)
			level_container.activate(false)
			player.activate(false)
#endregion

func start_game() -> void:
	change_game_state(GameState.PAUSE)
	var menu = main_menu.instantiate()
	ui.add_child(menu)
	menu.setup(self)
