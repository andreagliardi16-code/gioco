extends Node

enum Direction {NORTH, EAST, SOUTH, WEST, NULL}
enum Outcome {OK, FAIL}

var debug_mode: bool = true

func translate_direction_x(dir: Direction) -> int:
	match dir:
		Direction.EAST:
			return 1
		Direction.WEST:
			return -1
		_:
			return 0
