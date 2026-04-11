#è un dizionario che contiene variabili bool riguardo i potenziamenti
#utilizzabili dal player e alcuni dati sulle risorse che usano

class_name PowerUpData

extends Resource

@export var power_ups: Dictionary = {
	"jump" : {
		"active" : false,
		"cost" : 0.0 },
	"dash" : {
		"active" : false,
		"cost" : 3.0 },
	"wall_jump" : {
		"active" : false,
		"cost" : 0.5 },
	"freeze" : {
		"active" : false,
		"cost" : 20.0 },
	"inv_gravity" : {
		"active" : false,
		"cost" : 45.0 },
	"shrink_swell" : {
		"active" : false,
		"cost" : 10.0 },
	"arpoon" : {
		"active" : false,
		"cost" : 15.0 }
}
