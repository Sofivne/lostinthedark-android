extends Node2D

@onready var animation_intro = $AnimationPlayer

func _ready() -> void:
	animation_intro.play("Intro_Fade_In")
	get_tree().create_timer(3).timeout.connect(fade_out)

func fade_out():
	animation_intro.play("Intro_Fade_Out")
	get_tree().create_timer(3).timeout.connect(start_main_menu)


func start_main_menu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
