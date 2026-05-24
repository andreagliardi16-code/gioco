extends Node2D


##Script che assegna un attrito alla piattaforma e permette di essere riconosciuta come tale
@export var platform_material: PlatformMaterial = null

@onready var platform: AnimatableBody2D = $Platform
@onready var sprite: Node2D = $Platform/WigglePivot


func _ready() -> void:
	platform.platform_material  = platform_material


## Funzione da chiamare direttamente dal keyframe dell'AnimationPlayer (Method Call Track).
## Crea un effetto wiggle rapido e asimmetrico per avvisare il giocatore.
func trigger_wiggle() -> void:
	if not sprite:
		return
	
	# Parametri locali per fare modifiche al volo senza riempire l'inspector
	var wiggle_amplitude: float = deg_to_rad(12.0) # Ampiezza dell'oscillazione in gradi
	var total_duration: float = 0.35 # Durata totale dello wiggle prima della rotazione
	
	# Creiamo un Tween sequenziale (set_parallel(false) è il default, ma lo esplicitiamo)
	var tween: Tween = create_tween().set_parallel(false)
	
	# Salviamo la rotazione iniziale dello sprite per resettarla alla fine
	var start_rot: float = sprite.rotation
	
	# 1. Scatto rapido a sinistra
	tween.tween_property(sprite, "rotation", start_rot - wiggle_amplitude, total_duration * 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# 2. Contro-scatto ampio a destra (crea l'effetto molla/anticipazione)
	tween.tween_property(sprite, "rotation", start_rot + (wiggle_amplitude * 0.8), total_duration * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# 3. Ritorno perfetto al centro prima che l'AnimationPlayer faccia ruotare tutta la piattaforma
	tween.tween_property(sprite, "rotation", start_rot, total_duration * 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
