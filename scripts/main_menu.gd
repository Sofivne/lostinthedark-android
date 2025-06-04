extends Control

@onready var Audio = $AudioStreamPlayer2D
@onready var ButtonPlay = $"[Btn]Start"

func _ready() -> void:
	print("test")
	if ButtonPlay:
		print("pressed")
		ButtonPlay.connect("pressed", Callable(self, "_on_StartButton_pressed"))
	Audio.play()

func _on_StartButton_pressed() -> void:
	start_game()

func start_game() -> void:
	get_tree().change_scene_to_file("res://stages/stage0.tscn")
