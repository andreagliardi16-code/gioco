extends Resource
class_name LevelsList

# questo dizionario è estremamente importante. Collega delle stringhe alle
# packed scene (file .tscn) dei livelli veri e propri, in modo da poter tenere,
# nelle aree che si occupano di collegare le stanze, solo una stringa e non 
# l'intera scena. Tuttavia è fondamentale che le stanze abbiano nomi 
# identificativi e unici. Se si sbaglia stringa il collegamento tra un area e
# l'altra non funziona.

@export var list: Dictionary = {
	&"test_level" : null,
	&"tutorial_flashback" : null,
	&"tutorial_room" : null,
	&"respawn_room" : null
}
