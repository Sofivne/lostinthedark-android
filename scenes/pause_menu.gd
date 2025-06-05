extends Control

func _ready():
	print("SaveManager est accessible :", SaveManager)
	
	$CanvasLayer/Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$CanvasLayer/Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$CanvasLayer/Panel/VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)

func _on_resume_pressed():
	get_tree().paused = false
	queue_free()

func _on_quit_pressed():
	get_tree().quit()

func _on_save_pressed():
	if SaveManager == null:
		push_error("SaveManager est null lors de l'appui sur le bouton.")
		return
	SaveManager.save_game()
