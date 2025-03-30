extends Node3D
@onready var spawns = $Spawns
@onready var navigationRegion = $NavigationRegion3D

var zombie = load("res://Level2/Zombie/zombie.tscn")
var instance
func _ready():
	randomize()



func getRandomChild(parentNode):
	var randomId = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomId)

func _on_zombie_spawn_timer_timeout() -> void:
	var spawnPoint = getRandomChild(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawnPoint
	instance.scale = Vector3(0.7, 0.7, 0.7)
	navigationRegion.add_child(instance)
