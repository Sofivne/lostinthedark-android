extends Node
var player_ref: CharacterBody2D = null
var pending_load_data: Dictionary = {}
func get_player_position() -> Vector2:
	if player_ref:
		return player_ref.global_position
	else:
		push_warning("Référence au joueur manquante.")
		return Vector2.ZERO
