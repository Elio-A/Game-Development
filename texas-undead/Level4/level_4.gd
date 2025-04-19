extends Node3D
@onready var spawnsa = $Spawns1
@onready var spawnsb = $Spawns2
@onready var navigationRegion = $Ground

@onready var hitRectangle = $UI
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar
@onready var groceryDoor = $Door
@onready var stairsPath = $StaticBody3D/NextLevel

func _ready():
	groceryDoor.monitoring = true
	stairsPath.monitoring = false


var playerHealth = 100
var zombie = load("res://Level4/Zombie/zombie.tscn")
var instance

var zombieCounter = 0
	
func getRandomChild(parentNode):
	var randomId = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomId)

func _on_zombie_spawn_timer_timeout() -> void:
	if zombieCounter >= 15:
		return
	var spawnPoint
	if zombieCounter <= 8:
		spawnPoint = getRandomChild(spawnsa).global_position
	else:
		spawnPoint = getRandomChild(spawnsb).global_position
	instance = zombie.instantiate()
	instance.position = spawnPoint
	instance.scale = Vector3(0.7, 0.7, 0.7)
	navigationRegion.add_child(instance)
	zombieCounter += 1

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


func _on_door_body_entered(body: Node3D) -> void:
	print(body.get_groups())
	if(body.is_in_group("Player")):
		print("New Weapon Acquired")
		stairsPath.monitoring = true
		groceryDoor.monitoring = false
		

func _on_next_level_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
			moveToNextLevel()
		

func moveToNextLevel():
	pass #For now
	#Replace player with scene 2
	get_tree().change_scene_to_file("res://Level5/Level5.tscn")
