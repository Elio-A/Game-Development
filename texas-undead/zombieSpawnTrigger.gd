extends Area3D

@export var playerGroup: String = "Player"

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group(playerGroup):
		activateZombies()

func activateZombies():
	var zombies = get_tree().get_nodes_in_group("Zombie")
	for zombie in zombies:
		if zombie.has_method("activate"):
			print("Activating zombie now")
			zombie.activate()
