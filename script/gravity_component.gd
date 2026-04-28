#Si chiama quando un oggetto deve essere soggetto all'accelerazione
#di gravità e in base allo stato dell'oggetto passa alla componente
#del movimento la giusta istanza di movimento.

class_name GravityComponent

extends Node

enum GravityModes {GROUNDED, NORMAL, FALL, JUMP_CUT}

var parent: Node2D= null
var parent_stats: Stats= null

var gravity_direction: int= -1
var curr_grav_mode: GravityModes

#region setup
func setup(stats: Stats, owner_node: Node2D):
	if stats == null or owner_node == null:
		print("errore in setup gravity")
	parent_stats = stats
	parent = owner_node
#endregion

#region gravity
func change_gravity_direction() -> void:
	#inserire controllo se necessario
	gravity_direction *= -1

func change_gravity_state(new_state: GravityModes) -> void:
	curr_grav_mode = new_state

func get_gravity() -> float:
	match curr_grav_mode:
		GravityModes.GROUNDED:
			return 0.0
		GravityModes.NORMAL:
			return parent_stats.default_gravity
		GravityModes.JUMP_CUT:
			return parent_stats.cut_gravity
		GravityModes.FALL:
			return parent_stats.fall_gravity
		_:
			print("Error in gravity state detection")
			return 0.0
#endregion

#region state
func update_gravity() -> void:
	if parent.curr_physic_state == Player.PhysicsStates.GROUND:
		if curr_grav_mode != GravityModes.GROUNDED:
			change_gravity_state(GravityModes.GROUNDED)
			return
	elif parent.curr_physic_state == Player.PhysicsStates.AIR:
		if parent.movement.jump_cut_timer > 0.0:
			if curr_grav_mode != GravityModes.JUMP_CUT:
				change_gravity_state(GravityModes.JUMP_CUT)
			return
		if parent.curr_player_state == Player.PlayerStates.JUMP or parent.curr_player_state == Player.PlayerStates.POGO:
			if curr_grav_mode != GravityModes.NORMAL:
				change_gravity_state(GravityModes.NORMAL)
				return
		else:
			if curr_grav_mode != GravityModes.FALL:
				change_gravity_state(GravityModes.FALL)
				return
#endregion
