extends CharacterBody2D
class_name Player

enum MovementState {
	IDLE,
	RUNNING_LEFT,
	RUNNING_RIGHT,
	JUMPING,
	FALLING,
	DOUBLE_JUMP
}
var pause_menu_instance: Node = null
const PauseMenuScene = preload("res://scenes/pause_menu.tscn")
const GameOverScene = preload("res://scenes/game_over.tscn")


@export var speed: float = 90.0
@export var jump_height: float = 65.0
@export var time_jump_apex: float = 0.4

@onready var mini_game = $MiniGame
@onready var animation_player = $animation 
@onready var footstep_sound = $FootstepSound

var gravity: float
var jump_force: float
var on_ground: bool = false
var can_double_jump: bool = false
var is_double_jumping: bool = false
var current_lamp = null

var total_lampes: int = 0
var lampes_allumees: int = 0
var can_move: bool = false  

signal all_lamps_on

func _ready():
	if GameManager.pending_load_data.size() > 0:
		var data = GameManager.pending_load_data
		global_position = Vector2(data["position"]["x"], data["position"]["y"])
		PlayerGlobalStates.health = data["health"]
		check_game_over()
		GameManager.pending_load_data = {}
	gravity = (2 * jump_height) / pow(time_jump_apex, 2)
	jump_force = gravity * time_jump_apex
	HudManager.set_label_visible($Label, false)
	$Label.visible = false
	GameManager.player_ref = self
	mini_game.connect("mini_game_success", Callable(self, "_on_mini_game_success"))
	mini_game.connect("mini_game_failed", Callable(self, "_on_mini_game_failed")) 
	print("Player ready")
	print("MiniGame visibility: ", mini_game.visible)
	init_lampes()

func init_lampes():
	var lamps = get_tree().get_nodes_in_group("lamps")
	total_lampes = lamps.size()
	for lamp in lamps:
		lamp.connect("lampe_allumee", Callable(self, "_on_lampe_allumee"))
	HudManager.update_label($Label, lampes_allumees, total_lampes)

	
func _on_lampe_allumee():
	lampes_allumees += 1
	HudManager.update_label($Label, lampes_allumees, total_lampes)
	HudManager.set_label_visible($Label, true)
	#$Label.visible = true
	get_tree().create_timer(2.0).connect("timeout", Callable(self, "_on_label_timer_timeout"))
	if lampes_allumees == total_lampes:
		print("All lamps are on")
		emit_signal("all_lamps_on")

func _on_label_timer_timeout():
	$Label.visible = false
	

func _physics_process(delta: float):
	velocity.y += gravity * delta
	var pos = GameManager.get_player_position()
	print("Position actuelle :", pos)
	if can_move:
		var was_moving = velocity.x != 0
		if Input.is_action_just_pressed("ui_select"):
			PlayerGlobalStates.reduce_health(25)
			check_game_over()
		if Input.is_action_pressed("ui_left"):
			move_left()
		elif Input.is_action_pressed("ui_right"):
			move_right()
		else:
			velocity.x = 0

		if Input.is_action_just_pressed("ui_up"):
			jump()

		if Input.is_action_just_pressed("move_down") and on_ground:
			move_down()

		var is_moving = velocity.x != 0

		if on_ground:
			if is_moving and !was_moving:
				if not footstep_sound.playing:
					footstep_sound.play()
			elif !is_moving and was_moving:
				if footstep_sound.playing:
					footstep_sound.stop()
		else:
			if footstep_sound.playing:
				footstep_sound.stop()
	else:
		velocity.x = 0

	move_and_slide()

	if is_on_floor():
		on_ground = true
		can_double_jump = false
		is_double_jumping = false
		
		if velocity.x == 0:
			#$animation.play("idle")
			set_animation_state(MovementState.IDLE)
		else:
			set_animation_state(MovementState.RUNNING_RIGHT if velocity.x > 0 else MovementState.RUNNING_LEFT)
	else:
		on_ground = false
		if velocity.y < 0:
			if is_double_jumping:
				set_animation_state(MovementState.DOUBLE_JUMP)
			else:
				set_animation_state(MovementState.JUMPING)

		else:
			set_animation_state(MovementState.FALLING)
			
			

			
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()
 
		
func pause_game():
	get_tree().paused = true
	pause_menu_instance = PauseMenuScene.instantiate()
	pause_menu_instance.name = "PauseMenu"
	get_tree().get_root().add_child(pause_menu_instance)

func resume_game():
	get_tree().paused = false
	if pause_menu_instance and pause_menu_instance.is_inside_tree():
		pause_menu_instance.queue_free()
	pause_menu_instance = null


func move_right():
	velocity.x = speed
	$animation.flip_h = false  

func move_left():
	velocity.x = -speed
	$animation.flip_h = true

func jump():
	if on_ground:
		velocity.y = -jump_force
		on_ground = false
		can_double_jump = true
	else:
		if can_double_jump:
			velocity.y = -jump_force
			can_double_jump = false
			is_double_jumping = true

func _on_Area2D_body_exited(body: Node):
	set_collision_layer_value(2, true)

func move_down():
	position.y += 1
	print("Moved down")

func start_mini_game(lamp):
	current_lamp = lamp
	can_move = false 
	mini_game.show()
	mini_game.start_mini_game(lamp)
	print("Mini-game position: %s" % str(mini_game.position))
	print("MiniGame visibility après show: ", mini_game.visible)
	print("MiniGame Z-Index: ", mini_game.z_index)

func _on_mini_game_success():
	can_move = true 
	if current_lamp != null:
		current_lamp.allumer_lampe()
		current_lamp = null

func _on_mini_game_failed():
	print("Mini-jeu échoué, réduction de santé.")
	PlayerGlobalStates.reduce_health(10)
	check_game_over()
	can_move = true
	
func check_game_over():
	if PlayerGlobalStates.health <= 0:
		print("Game Over")
		get_tree().paused = true
		var game_over_instance = GameOverScene.instantiate()
		game_over_instance.name = "GameOver"
		get_tree().get_root().add_child(game_over_instance)

	

func set_animation_state(state: MovementState):
	match state:
		MovementState.IDLE:
			$animation.play("idle")
		MovementState.RUNNING_LEFT:
			$animation.play("run")
			$animation.flip_h = true
		MovementState.RUNNING_RIGHT:
			$animation.play("run")
			$animation.flip_h = false
		MovementState.JUMPING:
			$animation.play("jump")
		MovementState.FALLING:
			$animation.play("fall")
		MovementState.DOUBLE_JUMP:
			$animation.play("doubleJump")
