extends Control

@onready var Audio = $AudioStreamPlayer2D
@onready var ButtonNewGame = $"VBoxContainer/New Game"
@onready var ButtonLoadGame = $"VBoxContainer/Load Game"
@onready var ButtonSettings = $"VBoxContainer/Settings"
@onready var ButtonQuit = $"VBoxContainer/Quit"

func _ready() -> void:
	if ButtonNewGame:
		ButtonNewGame.connect("pressed", Callable(self, "_on_StartButton_pressed"))
	if ButtonLoadGame:
		ButtonLoadGame.connect("pressed", Callable(self, "_on_LoadButton_pressed"))
	if ButtonSettings:
		ButtonSettings.connect("pressed", Callable(self, "_on_SettingsButton_pressed"))
	if ButtonQuit:
		ButtonQuit.connect("pressed", Callable(self, "_on_QuitButton_pressed"))
	Audio.play()

func _on_StartButton_pressed() -> void:
	start_game()

func _on_LoadButton_pressed() -> void:
	load_game()

func _on_SettingsButton_pressed() -> void:
	open_settings()

func _on_QuitButton_pressed() -> void:
	quit_game()

func start_game() -> void:
	get_tree().change_scene_to_file("res://stages/stage0.tscn")

func load_game() -> void:
	print("Load game functionality here")

func open_settings() -> void:
	print("Settings menu functionality here")

func quit_game() -> void:
	print("Quit button pressed")
	get_tree().quit()
