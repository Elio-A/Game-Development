extends Area3D

@export var playerGroup: String = "Player"
@onready var originalCam = $"../../Player/Head/Camera3D"
@onready var secondCam = $"../../StaticCam"
var areaActivated = false

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if areaActivated == false:
		if body.is_in_group(playerGroup):
			areaActivated = true
			switchCamera()
			activateZombies()
			deactivateArea()

func switchCamera():
	if secondCam:
		secondCam.current = true
		await get_tree().create_timer(4.0).timeout
		originalCam.current = true

func activateZombies():
	var zombies = get_tree().get_nodes_in_group("Zombie")
	for zombie in zombies:
		if zombie.has_method("activate"):
			zombie.activate()

func deactivateArea():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
