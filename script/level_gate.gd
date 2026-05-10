@tool

extends Area2D
class_name LevelGate


signal new_gate_id(new_id: StringName, old_id: StringName, gate: LevelGate)


@export_group("Collegamento tra Livelli")
@export var gate_ptr: StringName = &""
@export var own_ptr: StringName:
	set(value):
		old_own_ptr = own_ptr
		own_ptr = value
		emit_signal("new_gate_id", own_ptr, old_own_ptr, self)
@export_group("Posizione Spawn")
@export var player_height: float = 80.0
@export var facing_direction: Global.Direction = Global.Direction.NULL
@export var adjust_now: bool:
	set(value):
		if value:
			_adjust_spawn_pos()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var marker: Marker2D = $Marker2D

var spawn_pos: Vector2 = Vector2.ZERO
var level_map: LevelMap = LevelMap.new()
var old_own_ptr: StringName


#region process e ready
func _ready() -> void:
	if Engine.is_editor_hint():
		pass 
	else:
		_adjust_spawn_pos()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()
#endregion


#region posizione spawn
func _adjust_spawn_pos()-> void:
	if not collision_shape or not collision_shape.shape is RectangleShape2D:
		push_warning("L'area di collisone non è impostata nel modo giusto, impossibile generare punto di spawn")
		return
	
	var shape: RectangleShape2D = collision_shape.shape
	var extents: Vector2 = shape.size/2
	var y: float = extents.y - player_height / 2.0
	
	spawn_pos.y = y
	
	match facing_direction:
		Global.Direction.EAST:
			spawn_pos.x = extents.x
		Global.Direction.WEST:
			spawn_pos.x = -extents.x
		_:
			spawn_pos = Vector2.ZERO
			push_error("L'entrata di un livello può essere rivolta solo a destra o sinistra")
	
	_position_marker()


func _position_marker() -> void:
	marker.position = spawn_pos
#endregion


func _get_configuration_warnings() -> PackedStringArray:
	var string: PackedStringArray 
	
	string.append("Assicurati di posizionare l'area in modo che non possa essere aggirata")
	
	if own_ptr == &"":
		string.append("Assegnare un identificativo a questo collegamento")
	
	if gate_ptr == &"":
		string.append("Assegnare l'identificatore dell'entrata al livello successivo collegata a quest'area.\n Assicurarsi che esista nel livello desiderato (un errore non viene identificato automaticamente).")
	
	return string
