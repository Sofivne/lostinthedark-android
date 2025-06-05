extends Node

var current_hud: Node = null

var hud_elements = [
	"forward",
	"backward",
	"jump",
	"potentiometer",
	"black_button",
	"white_button",
	"blue_button"
]

func set_current_hud(hud: Node):
	current_hud = hud
	if current_hud:
		print("HUD actif défini :", current_hud)
	else:
		print("Erreur : Aucun HUD n'a été défini.")

func update_health_value(new_health):
	if current_hud:
		var animated_sprite = current_hud.get_node_or_null("Heart")
		if animated_sprite:
			new_health = clamp(new_health, 0, 100)
			print("NEW HEALTH DEBUG" ,new_health)
			var frame_index = int((100 - new_health) / 10.0)
			frame_index = clamp(frame_index, 0, 10)
			print("FRAME_INDEX DEBUG", frame_index)

			animated_sprite.frame = frame_index
			print("ANIMATED SPRITE FRAME",animated_sprite.frame)
			print("Affichage mis à jour avec la santé :", new_health, ", frame :", frame_index)
		else:
			print("Erreur : AnimatedSprite2D introuvable dans le HUD.")
	else:
		print("Erreur : Aucun HUD actif défini.")


func hide_all_labels():
	if current_hud:
		for element in hud_elements:
			var node = current_hud.get_node_or_null(element)
			if node:
				node.visible = false
			else:
				print("Erreur : nœud introuvable :", element)

func show_all_labels():
	if current_hud:
		for element in hud_elements:
			var node = current_hud.get_node_or_null(element)
			if node:
				node.visible = true
			else:
				print("Erreur : nœud introuvable :", element)


func update_label(node_control: Label, current_value: float, total_value:float):
	node_control.text = "%d/%d" % [current_value, total_value]

func set_label_visible(node_label_timeout: Label, state: bool):
	node_label_timeout.visible = state
	
