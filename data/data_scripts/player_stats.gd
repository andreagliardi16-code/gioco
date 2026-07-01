#contiene tutti i parametri di statistiche del player

class_name PlayerStats

extends Stats

#region gravity
@export_group("Gravity")
@export var default_gravity: float = 1666.7  #formula = 2h/t^2 (valore assoluto)
@export var fall_gravity: float = 2300.0
@export var cut_gravity: float = 3100.0  #da testare
#endregion

#region jump movement
@export_group("Jump")
@export var jump_force: float = -1000.0  #formula = 2H/t
@export var coyote_time: float = 0.25
@export var min_jump_time: float = 0.1
#endregion

#region horizontal movement
@export_group("Horizontal Movement")
@export var max_speed: int = 280 #pixel al secondo
@export var acceleration: float = 840 #tempo di accelerazione circa 0.33 s
@export var deceleration: float = 1400.0 #decelerazione in 0.2 secondi
@export var max_speed_change: int = 1000
#endregion

#region camera
@export_group("Camera")
@export var zoom: float = 1
##coefficente che determina relazione tra distanza player centro cam e velocità del player
@export var distance_n: float = 0.1  
@export var max_distance: int = 80   #massima distanza in pixel dal player al centro della camera
@export var x_pan_target: int = 600
@export var y_pan_target: int = 300
#endregion

#region dash
@export_group("Dash")
@export var dash_speed_amt: int = 2000  #pixel al secondo. Velocità dash
@export var dash_time: float = 0.2  
@export var dash_cut: float = -1200 #dovrebbe essere un numero negativoa
@export var dash_cooldown: float = 0.45
#endregion

#region energy
@export_group("Energy")
@export var max_energy: int = 100
@export var regen_rate: float = 0.0
@export var max_cooldown: float = 5.0
@export var max_regen_time: float = 3.5
#endregion

#region pogo
@export_group("Pogo")
@export var side_force: float = 1500
@export var vertical_force: float = -1000
@export var impulse_duration: float = 0.15
@export var fade_duration: float = 0.3
@export var area_detection_time: float = 0.15
#endregion
