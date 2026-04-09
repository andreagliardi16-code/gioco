#L'area di base fa in modo che il player non cada nel vuoto rilevando le
#collisioni con il pavimento, inoltre rileva il metadato allegato a ogni
#superficie che determina il coefficente d'attrito

class_name BaseArea

extends Area2D

const AIR_FRICTION: float = 0.5

var parent
var on_floor: bool = false
var current_areas: Array = []

func setup(parent_node: Node2D) -> void:
	parent = parent_node
	parent.friction = AIR_FRICTION

func change_friction(area: Node2D = null) -> float:
	if area == null:
		return AIR_FRICTION
	#if current_areas.is_empty():
		#return AIR_FRICTION
	
	var max_friction : float = AIR_FRICTION
	for n in current_areas:
		if area.platform_material:
			var f = area.platform_material.value
			if f > max_friction:
				max_friction = f
	
	return max_friction

func _on_body_entered(body: Node2D) -> void:
	current_areas.append(body)
	on_floor = true
	#if body:
		#print("ohi, body: ", body)
	
	parent.friction = change_friction(body)

func _on_body_exited(body: Node2D) -> void:
	current_areas.erase(body)
	on_floor = current_areas.size()>0
	parent.friction = change_friction(body)
	if not on_floor:
		parent.start_coyote_time()
