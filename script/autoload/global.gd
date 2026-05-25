extends Node

signal data_ready()


enum Direction {NORTH, EAST, SOUTH, WEST, NULL}
enum Outcome {OK, FAIL}


var game_manager: GameManager = null
var player_stats: PlayerStats = null
var physics_stats: PhysicsStats = null

var spawn_level_id: StringName = &""
var debug_mode: bool = false


func translate_direction_x(dir: Direction) -> int:
	match dir:
		Direction.EAST:
			return 1
		Direction.WEST:
			return -1
		_:
			return 0


func set_spawn_level(id: StringName) -> void:
	spawn_level_id = id


func set_game_manager(gm: GameManager, pl_st: PlayerStats, phy_st: PhysicsStats) -> Global.Outcome:
	if not gm or not pl_st or not phy_st:
		return Global.Outcome.FAIL
	
	game_manager = gm
	player_stats = pl_st
	physics_stats = phy_st
	
	data_ready.emit()
	
	return Global.Outcome.OK


# DA RIFARE
func change_game_spawn(level_id: StringName, spawn_id: StringName) -> void:
	var err = game_manager.change_spawn_data(spawn_id, level_id)
	if err != Global.Outcome.OK:
		push_error("Il processo di cambio dei dati di spawn ha fallito")
	
	print("primo_livello e primo spawn: ", level_id, spawn_id)
