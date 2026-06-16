@tool

extends PogoableArea
class_name TimedPogoableArea

const TIMEOUT: int = 3

enum State {ON, OFF}

var curr_state: State = State.ON


func used() -> void:
	self._switch(false)
	_update_state(State.OFF)
	
	await get_tree().create_timer(TIMEOUT).timeout
	
	self._switch(true)
	_update_state(State.ON)


func _update_state(new_state: State) -> void:
	curr_state = new_state
