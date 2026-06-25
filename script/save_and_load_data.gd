extends Resource
class_name DataSaver


const DATA_CONFIG_PATH: String = "res://ext_game_data/game_data.json"

@export var player_stats: PlayerStats
@export var world_stats: PhysicsStats


#region game data
func _save_to_json() -> Global.Outcome:
	if not player_stats or not world_stats:
		return Global.Outcome.FAIL
	
	var data_dict: Dictionary = {
		"player_stats": {
			"gravity": {
				"default_gravity": player_stats.default_gravity,
				"fall_gravity" : player_stats.fall_gravity,
				"cut_gravity" : player_stats.cut_gravity
			},
			"jump" : {
				"jump_force": player_stats.jump_force,
				"coyote_time": player_stats.coyote_time,
				"jump_cut_time": player_stats.jump_cut_time,
				"min_jump_time": player_stats.min_jump_time,
				"max_jump_time": player_stats.max_jump_time
			},
			"horizontal_movement" : {
				"max_speed": player_stats.max_speed,
				"acceleration": player_stats.acceleration,
				"deceleration": player_stats.deceleration,
				"max_speed_change": player_stats.max_speed_change, 
			},
			"camera" : {
				"zoom" : player_stats.zoom,
				"distance_n": player_stats.distance_n,
				"max_distance": player_stats.max_distance, 
				"x_pan_target": player_stats.x_pan_target, 
				"y_pan_target": player_stats.y_pan_target
			},
			"dash" : {
				"dash_speed_amt": player_stats.dash_speed_amt,
				"dash_time": player_stats.dash_time,
				"dash_cut": player_stats.dash_cut,
				"dash_cooldown": player_stats.dash_cooldown
			},
			"energy": {
				"max_energy": player_stats.max_energy,
				"regen_rate": player_stats.regen_rate,
				"max_cooldown": player_stats.max_cooldown,
				"max_regen_time": player_stats.max_regen_time
			},
			"pogo": {
				"side_force": player_stats.side_force,
				"vertical_force": player_stats.vertical_force,
				"impulse_duration": player_stats.impulse_duration,
				"fade_duration": player_stats.fade_duration,
				"area_detection_time": player_stats.area_detection_time
			}
		},
		"world_stats": {
			"friction": {
				"air_friction": world_stats.air_friction,
				"def_material_friction": world_stats.def_material_friction
			},
			"gates": {
				"gate_spawn_offset": world_stats.gate_spawn_offset
			}
		}
	}
	
	var json_string := JSON.stringify(data_dict, "\t")
	var file := FileAccess.open(DATA_CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		return Global.Outcome.FAIL
	
	file.store_string(json_string)
	file.close()
	return Global.Outcome.OK


func load_from_json() -> Global.Outcome:
	if not FileAccess.file_exists(DATA_CONFIG_PATH) or not player_stats or not world_stats:
		return Global.Outcome.FAIL
	
	var file := FileAccess.open(DATA_CONFIG_PATH, FileAccess.READ)
	var json_string :String = file.get_as_text()
	file.close()
	
	var json :JSON = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Impossibile leggere il file json")
		return Global.Outcome.FAIL
	
	var data: Dictionary = json.get_data()
	
	# ==========================================
	# 1. PARSING PLAYER STATS
	# ==========================================
	if data.has("player_stats"):
		var p_data: Dictionary = data["player_stats"]
		
		# --- Gravity ---
		if p_data.has("gravity"):
			var g: Dictionary = p_data["gravity"]
			player_stats.default_gravity = g.get("default_gravity", player_stats.default_gravity)
			player_stats.fall_gravity = g.get("fall_gravity", player_stats.fall_gravity)
			player_stats.cut_gravity = g.get("cut_gravity", player_stats.cut_gravity)
		
		# --- Jump ---
		if p_data.has("jump"):
			var j: Dictionary = p_data["jump"]
			player_stats.jump_force = j.get("jump_force", player_stats.jump_force)
			player_stats.coyote_time = j.get("coyote_time", player_stats.coyote_time)
			player_stats.jump_cut_time = j.get("jump_cut_time", player_stats.jump_cut_time)
			player_stats.min_jump_time = j.get("min_jump_time", player_stats.min_jump_time)
			player_stats.max_jump_time = j.get("max_jump_time", player_stats.max_jump_time)
			
		# --- Horizontal Movement ---
		if p_data.has("horizontal_movement"):
			var hm: Dictionary = p_data["horizontal_movement"]
			player_stats.max_speed = hm.get("max_speed", player_stats.max_speed)
			player_stats.acceleration = hm.get("acceleration", player_stats.acceleration)
			player_stats.deceleration = hm.get("deceleration", player_stats.deceleration)
			player_stats.max_speed_change = hm.get("max_speed_change", player_stats.max_speed_change)
			
		# --- Camera ---
		if p_data.has("camera"):
			var cam: Dictionary = p_data["camera"]
			player_stats.zoom = cam.get("zoom", player_stats.zoom)
			player_stats.distance_n = cam.get("distance_n", player_stats.distance_n)
			player_stats.max_distance = cam.get("max_distance", player_stats.max_distance)
			player_stats.x_pan_target = cam.get("x_pan_target", player_stats.x_pan_target)
			player_stats.y_pan_target = cam.get("y_pan_target", player_stats.y_pan_target)
			
		# --- Dash ---
		if p_data.has("dash"):
			var d: Dictionary = p_data["dash"]
			player_stats.dash_speed_amt = d.get("dash_speed_amt", player_stats.dash_speed_amt)
			player_stats.dash_time = d.get("dash_time", player_stats.dash_time)
			player_stats.dash_cut = d.get("dash_cut", player_stats.dash_cut)
			player_stats.dash_cooldown = d.get("dash_cooldown", player_stats.dash_cooldown)
			
		# --- Energy ---
		if p_data.has("energy"):
			var e: Dictionary = p_data["energy"]
			player_stats.max_energy = e.get("max_energy", player_stats.max_energy)
			player_stats.regen_rate = e.get("regen_rate", player_stats.regen_rate)
			player_stats.max_cooldown = e.get("max_cooldown", player_stats.max_cooldown)
			player_stats.max_regen_time = e.get("max_regen_time", player_stats.max_regen_time)
			
		# --- Pogo ---
		if p_data.has("pogo"):
			var po: Dictionary = p_data["pogo"]
			player_stats.side_force = po.get("side_force", player_stats.side_force)
			player_stats.vertical_force = po.get("vertical_force", player_stats.vertical_force)
			player_stats.impulse_duration = po.get("impulse_duration", player_stats.impulse_duration)
			player_stats.fade_duration = po.get("fade_duration", player_stats.fade_duration)
			player_stats.area_detection_time = po.get("area_detection_time", player_stats.area_detection_time)

	# ==========================================
	# 2. PARSING WORLD STATS
	# ==========================================
	if data.has("world_stats"):
		var w_data: Dictionary = data["world_stats"]
		
		# --- Friction ---
		if w_data.has("friction"):
			var f: Dictionary = w_data["friction"]
			world_stats.air_friction = f.get("air_friction", world_stats.air_friction)
			world_stats.def_material_friction = f.get("def_material_friction", world_stats.def_material_friction)
			
		# --- Gates ---
		if w_data.has("gates"):
			var gate: Dictionary = w_data["gates"]
			world_stats.gate_spawn_offset = gate.get("gate_spawn_offset", world_stats.gate_spawn_offset)

	# ==========================================
	# 3. AGGIORNAMENTO UI
	# ==========================================
	notify_property_list_changed()
	print("JSONDataBridge: Dati caricati e sincronizzati con successo dal JSON.")
	
	return Global.Outcome.OK
#endregion
