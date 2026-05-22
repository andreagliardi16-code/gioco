extends Node

enum Direction {NORTH, EAST, SOUTH, WEST, NULL}
enum Outcome {OK, FAIL}

var debug_mode: bool = true

var spawn_level_id: StringName = &"test_level"

func translate_direction_x(dir: Direction) -> int:
	match dir:
		Direction.EAST:
			return 1
		Direction.WEST:
			return -1
		_:
			return 0


# Questa funzione deve essere chiamata da una sola area nel gioco. Cambia lo spawn
# permanentemente dal tutorial al punto di spawn normale
func change_game_spawn(level_id: StringName, spawn_id: StringName, player: Player) -> void:
	print("CAMBIO SPAWN GENERALE")
	spawn_level_id = level_id
	player.respawn.respawn_area = spawn_id
