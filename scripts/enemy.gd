extends CharacterBody2D
class_name Enemy

@export var speed: float = 60.0
@export var left_limit: int = -100
@export var right_limit: int = 100
@export var attack_cooldown: float = 1.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

var direction := -1
var start_position: Vector2
var player_in_range := false
var player_in_attack_range := false
var can_attack := true

func _ready():
	start_position = position
	animation.play("walk")

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.body_exited.connect(_on_attack_body_exited)

func _physics_process(delta):
	update_attack_area_position()

	if player_in_range:
		chase_player()
	else:
		patrol()

	move_and_slide()

func patrol():
	var distance = position.x - start_position.x
	velocity.x = direction * speed

	if distance > right_limit:
		direction = -1
	elif distance < left_limit:
		direction = 1

	update_sprite_orientation()
	animation.play("walk")

func chase_player():
	var player = get_closest_player()
	if not player:
		player_in_range = false
		return

	var dx = player.global_position.x - global_position.x
	if abs(dx) > 5:  # ignore si le joueur est trop centré
		direction = sign(dx)
	update_sprite_orientation()

	if player_in_attack_range:
		velocity.x = direction * speed
		if can_attack:
			attack()
	else:
		velocity.x = direction * speed
		animation.play("walk")

func attack():
	can_attack = false
	animation.play("attack")
	if PlayerGlobalStates.has_method("reduce_health"):
		PlayerGlobalStates.reduce_health(25)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func update_sprite_orientation():
	# Si le sprite regarde à gauche par défaut
	animation.flip_h = direction > 0


func update_attack_area_position():
	var offset = Vector2(16, 0)
	attack_area.position = offset * direction

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _on_attack_body_entered(body):
	if body.is_in_group("player"):
		player_in_attack_range = true

func _on_attack_body_exited(body):
	if body.is_in_group("player"):
		player_in_attack_range = false

func get_closest_player():
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return body
	return null
