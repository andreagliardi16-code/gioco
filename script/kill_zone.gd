@tool

extends Area2D
class_name KillZone

const SECURITY_TIMER: float = 2.0
const ID: StringName = &"KillZone"

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var sec_timer: float = 0


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
	else:
		handle_timers(delta)


func handle_timers(delta: float) -> void:
	if sec_timer > 0:
		sec_timer -= delta


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	
	if self.get_children().size() == 0:
		warnings.append("A shape must be assigned")
	
	return warnings


func _on_body_entered(body: Node2D) -> void:
	if sec_timer > 0 or body is not Player:
		return
	
	body.call_deferred("die")
	sec_timer = SECURITY_TIMER
