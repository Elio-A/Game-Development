extends Node3D

@onready var hitRectangle = $UI
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar

var playerHealth = 100

func _on_player_player_been_hit() -> void:
	# Hit screen
	hitRectangle.visible = true
	hitRectangle.modulate.a = 1.0 # Fully visible

	var tween = get_tree().create_tween()
	tween.tween_property(hitRectangle, "modulate:a", 0.0, 1)
	await tween.finished

	hitRectangle.visible = false

	
	#Damage dealing:
	playerHealth -= 10
	healthBar.value -= 10
	
	if playerHealth <= 0:
		print("Player dead!")
