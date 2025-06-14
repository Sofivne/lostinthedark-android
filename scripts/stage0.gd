extends Node2D

@onready var forward_label = $UI/Labels/forward
@onready var backward_label = $UI/Labels/backward
@onready var jump_label = $UI/Labels/jump
@onready var potentiometer_label = $UI/Labels/potentiometer
@onready var black_button = $UI/Labels/black_button
@onready var white_button = $UI/Labels/white_button
@onready var blue_button = $UI/Labels/blue_button
@onready var circle = $circle
@onready var indicator = $indicator

@onready var camera = $Cinematics/Camera2D
@onready var animation_player = $Cinematics/AnimationPlayer 
@onready var player = $player
@onready var spawn_sprite = $Cinematics/SpawnSprite
@onready var point_light = $Lights/PointLight2D
@onready var door = $Interactable/Door

var total_lampes: int = 0

func _ready():
	HudManager.set_current_hud($UI/CanvasLayer/HUD)  
	PlayerGlobalStates.connect("health_changed", Callable(HudManager, "update_health_value"))
	print("HUD et signal configurés pour Stage 1.")
	print("stage1 : ", PlayerGlobalStates.get_health())
	HudManager.update_health_value(PlayerGlobalStates.get_health())
	if camera:
		camera.make_current()
		print("Scene camera is now active")

	if player and animation_player and spawn_sprite and point_light:
		print("Player, AnimationPlayer, SpawnSprite, and PointLight2D found")
		disable_player_point_lights()
		player.visible = false
		HudManager.hide_all_labels()
		point_light.visible = true
		start_spawn_animation()
	else:
		print("Erreur : Player, AnimationPlayer, SpawnSprite, ou PointLight2D non trouvé")

	init_lampes()



func disable_player_point_lights():
	for child in player.get_children():
		if child is PointLight2D:
			child.queue_free()
			print("PointLight2D removed in player")

func start_spawn_animation():
	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))
		animation_player.play("SpawnAndZoom")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "SpawnAndZoom":
		spawn_sprite.visible = false
		point_light.visible = false
		player.visible = true 
		player.can_move = true 
		HudManager.show_all_labels()

func init_lampes():
	var lampes = get_tree().get_nodes_in_group("lamps")
	total_lampes = lampes.size()


	for lampe in lampes:
		lampe.connect("lampe_allumee", Callable(player, "_on_lampe_allumee"))


	player.init_lampes()

	player.connect("all_lamps_on", Callable(self, "_on_all_lampes_allumee"))

func _on_all_lampes_allumee():
	if door:
		print("All lamps are on, door should open now.")
		door.play_door_sound()
		door.enable_transition()
	else:
		print("Erreur : le nœud Door est introuvable.")
