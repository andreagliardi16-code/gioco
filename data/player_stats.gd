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
# altezza massima salto 300px    (prima proposta)
# tempo salita salto 0.6 secondi (prima proposta)
@export_group("Jump")
@export var jump_force: float = -1000.0  #formula = 2H/t
@export var coyote_time: float = 0.25
#endregion

#region horizontal movement
@export_group("Horizontal Movement")
@export var max_speed: int = 280 #pixel al secondo
@export var acceleration: float = 840 #tempo di accelerazione circa 0.33 s
@export var deceleration: float = 1400.0 #decelerazione in 0.2 secondi
#endregion

#region camera
@export_group("Camera")
@export var zoom: float = 1
@export var distance_n: float = 0.1  #coefficente che determina relazione tra distanza player centro cam e velocità del player
@export var max_distance: int = 80   #massima distanza in pixel dal player al centro della camera
@export var vertical_modifier: float = 300 #distanza in pixel della modifica verticale (con input)
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
#endregion

#region pogo
@export_group("Pogo")
@export var side_force: float = 1500
@export var vertical_force: float = -1000
#endregion
