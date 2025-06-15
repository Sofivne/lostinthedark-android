extends Node

func _ready():
	var player = null
	for stage in get_tree().get_root().get_children():
		if stage.name.begins_with("Stage"):
			player = stage.get_node_or_null("player")
			if player:
				break
	
	if player:
		player.can_move = true
	else:
		print("Erreur : Impossible de trouver le nœud Player dans aucun Stage")
