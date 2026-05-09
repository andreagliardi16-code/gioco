extends Node

enum Direction {NORTH, EAST, SOUTH, WEST, NULL}
enum Outcome {OK, FAIL}


func translate_direction_x(dir: Direction) -> int:
	match dir:
		Direction.EAST:
			return 1
		Direction.WEST:
			return -1
		_:
			return 0
