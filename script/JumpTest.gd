extends Node


@export var player: CharacterBody2D

var was_on_floor: bool = true
var is_tracking: bool = false
var start_y: float = 0.0
var peak_y: float = 0.0

func _input(event: InputEvent) -> void:
	# Premendo 'P' sulla tastiera si attiva il salto automatico perfetto
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		if player and player.is_on_floor() and not is_tracking:
			run_automated_jump_test(11)

func run_automated_jump_test(frames_to_hold: int = 1) -> void:
	print("\n=== BOT: Inizio salto controllato (Hold per ", frames_to_hold, " frame) ===")
	Input.action_press("jump")
	
	# Invece di un timer a tempo, aspettiamo un numero esatto di tick fisici
	for i in range(frames_to_hold):
		await get_tree().physics_frame
		
	Input.action_release("jump")
	print("=== BOT: Rilascio tasto 'jump' ===")

func _physics_process(_delta: float) -> void:
	if not player:
		return

	# 1. RILEVAMENTO INIZIO ASCEZA (Intercetta sia te che il Bot)
	if was_on_floor and not player.is_on_floor() and player.velocity.y < 0:
		is_tracking = true
		start_y = player.global_position.y
		peak_y = start_y

	# 2. AGGIORNAMENTO APICE (Mentre il personaggio sale)
	if is_tracking:
		if player.global_position.y < peak_y:
			peak_y = player.global_position.y
		
		# 3. APICE RAGGIUNTO (La velocità si inverte o tocca terra)
		if player.velocity.y >= 0 or player.is_on_floor():
			is_tracking = false
			var altezza_effettiva = start_y - peak_y
			
			# Stampa il report escludendo i micro-salti accidentali
			print("---------------------------------")
			print("🔍 TELEMETRIA DI SALTO OBIETTIVA")
			print("-> Altezza Massima: ", altezza_effettiva, " pixel")
			print("---------------------------------")

	# Salva lo stato per il frame successivo
	was_on_floor = player.is_on_floor()
