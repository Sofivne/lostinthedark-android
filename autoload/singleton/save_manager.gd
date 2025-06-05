extends Node
func save_game():
	if not GameManager.player_ref:
		push_error("Aucune référence au joueur dans GameManager. Impossible de sauvegarder.")
		return

	var player_pos: Vector2 = GameManager.get_player_position()
	var player_health: float = PlayerGlobalStates.health
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	var save_data = {
		"position": {
			"x": player_pos.x,
			"y": player_pos.y
		},
		"scene_path": current_scene_path,
		"health": player_health
	}

	var file_path = "user://save_data.json"

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Sauvegarde réussie :", save_data)
	else:
		push_error("Erreur : impossible d'ouvrir le fichier de sauvegarde.")


func load_game():
	var file_path = "user://save_data.json"
	if not FileAccess.file_exists(file_path):
		push_error("Fichier de sauvegarde introuvable.")
		return

	var file := FileAccess.open(file_path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var parsed_result = JSON.parse_string(content)
	if typeof(parsed_result) != TYPE_DICTIONARY:
		push_error("Sauvegarde corrompue.")
		return

	GameManager.pending_load_data = parsed_result

	var saved_scene_path = parsed_result.get("scene_path", "")
	print(saved_scene_path)
	if saved_scene_path != "":
		get_tree().change_scene_to_file(saved_scene_path)
	else:
		push_error("Chemin de scène absent de la sauvegarde.")
