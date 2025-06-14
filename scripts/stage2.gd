extends Node

func _ready():
	var player = get_node_or_null("/root/Stage1/player")
	if player == null:
		player = get_node_or_null("/root/Stage2/player")
	
	if player:
		player.can_move = true
	else:
		print("Erreur : Impossible de trouver le nœud Player dans aucun des chemins")
