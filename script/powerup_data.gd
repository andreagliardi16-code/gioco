#è un dizionario che contiene variabili bool riguardo i potenziamenti
#utilizzabili dal player e alcuni dati sulle risorse che usano

class_name PowerUpData

extends Resource

@export var power_ups: Dictionary = {
	"jump" : {
		"active" : false,
		"cost" : 0.0,
		"cooldown" : 0.0 },
	"dash" : {
		"active" : false,
		"cost" : 3.0,
		"cooldown" : 0.4 },
	"pogo" : {
		"active" : false,
		"cost" : 0.5,
		"cooldown" : 0.25 },
	"freeze" : {
		"active" : false,
		"cost" : 20.0,
		"cooldown" : 2.0 },
	"inv_gravity" : {
		"active" : false,
		"cost" : 45.0,
		"cooldown": 3.5 },
	"shrink_swell" : {
		"active" : false,
		"cost" : 10.0,
		"cooldown" : 2.0 },
	"arpoon" : {
		"active" : false,
		"cost" : 15.0,
		"cooldown" : 2.5 }
}
