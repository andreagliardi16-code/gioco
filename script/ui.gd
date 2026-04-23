extends CanvasLayer
class_name GameUi

func activate(switch: bool) -> void:
	visible = switch
	if switch:
		process_mode = Node.PROCESS_MODE_INHERIT
		return
	process_mode = Node.PROCESS_MODE_DISABLED
