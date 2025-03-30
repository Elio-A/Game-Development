extends Area3D

@export var playerGroup: String = "Player"
var areaActivated = false

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if areaActivated == false:
		if body.is_in_group(playerGroup):
			areaActivated = true
			activateZombies()
			deactivateArea()

func activateZombies():
	var zombies = get_tree().get_nodes_in_group("Zombie")
	for zombie in zombies:
		if zombie.has_method("activate"):
			zombie.activate()

func deactivateArea():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
