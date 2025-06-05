extends Node

signal health_changed(new_health)

var health: float = 100.0

func set_health(value: int) -> void:
	health = clamp(value, 0, 100)
	emit_signal("health_changed", health) 
	print("Santé mise à jour :", health)



func reduce_health(amount: int) -> void:
	set_health(health - amount)
	print(get_health())
	if health <= 0:
		handle_death()

func get_health() -> int:
	print(health)
	return health

func handle_death() -> void:
	print("Le joueur est mort !")
	emit_signal("health_changed", 0)
