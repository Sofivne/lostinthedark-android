extends Control

signal mini_game_success
signal mini_game_failed

var is_active = false
var target_angle = 0.0
var current_angle = 0.0
var flexibility = 20
var lamp_node = null
var was_on_target = false

@export var rotation_speed: float = 90.0
@export var rotation_speed_indicator: float = 10.0

@onready var circle = $Circle
@onready var indicator = $Circle/Indicator
@onready var success_sound = $AudioStreamPlayer_Success  
@onready var error_sound = $AudioStreamPlayer_Error 
@onready var animation_player = $AnimationPlayer


func _ready():
	circle.hide()
	indicator.hide()
	set_process(false)
	print("MiniGame ready")

	if circle == null:
		print("Erreur : nœud Circle non trouvé")
	else:
		print("Circle trouvé")
		print("Circle visibility: ", circle.visible)
	
	if indicator == null:
		print("Erreur : nœud Indicator non trouvé")
	else:
		print("Indicator trouvé")
		print("Indicator visibility: ", indicator.visible)

	print("MiniGame z_index: %d" % z_index)

	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start_mini_game(lamp):
	lamp_node = lamp
	is_active = true
	target_angle = round(randf() * 36.0) * 10.0
	current_angle = 0.0
	circle.show()
	indicator.show()
	set_process(true)
	print("MiniGame started")
	print("Target angle: %f" % target_angle)
	print("Current angle: %f" % current_angle)
	print("MiniGame position: %s" % str(global_position))
	print("Circle position: %s" % str(circle.global_position))
	print("Indicator position: %s" % str(indicator.global_position))
	print("Circle visibility après show: ", circle.visible)
	print("Indicator visibility après show: ", indicator.visible)
	print("MiniGame visibility après show: ", visible)
	print("MiniGame z_index après show: %d" % z_index)

func _process(delta):
	if not is_active:
		return

	if Input.is_action_pressed("scroll_up"):
		current_angle -= rotation_speed * delta
		print("Scroll up detected, current angle: %f" % current_angle)
	elif Input.is_action_pressed("scroll_down"):
		current_angle += rotation_speed * delta
		print("Scroll down detected, current angle: %f" % current_angle)

	current_angle = round(fmod(current_angle, 360.0) / 10.0) * 10.0
	indicator.rotation_degrees = current_angle

	var angle_diff = abs(indicator.rotation_degrees - target_angle)
	if angle_diff > 180.0:
		angle_diff = 360.0 - angle_diff

	var is_on_target = angle_diff <= flexibility
	if is_on_target and not was_on_target:
		success_sound.play()

	was_on_target = is_on_target

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			current_angle += rotation_speed_indicator
			print("Mouse wheel down, current angle: %f" % current_angle)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			current_angle -= rotation_speed_indicator
			print("Mouse wheel up, current angle: %f" % current_angle)
			
	if Input.is_action_just_pressed("validate"):
		print("Validate action detected")
		if is_active:
			check_distance_lock()

func check_distance_lock():
	var angle_diff = abs(indicator.rotation_degrees - target_angle)
	if angle_diff > 180.0:
		angle_diff = 360.0 - angle_diff

	print("Checking distance lock, angle difference: %f" % angle_diff)
	if angle_diff <= flexibility:
		print("Lock successful")
		is_active = false
		circle.hide()
		indicator.hide()
		set_process(false)
		emit_signal("mini_game_success")
	else:
		print("Lock unsuccessful, angle difference: ", angle_diff)
		is_active = false
		circle.hide()
		indicator.hide()
		set_process(false)
		error_sound.play()
		animation_player.play("error_animation")
		emit_signal("mini_game_failed")
