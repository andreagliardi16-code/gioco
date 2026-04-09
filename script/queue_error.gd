class_name QueueError

extends QueueItem

var error_arg: String

func _init(arg: Variant) -> void:
	id = &"error"
	life = 0.2
	priority = 11
	error_arg = arg
