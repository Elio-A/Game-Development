extends Node3D
@onready var spawns = $Spawns
@onready var navigationRegion = $Ground

@onready var hitRectangle = $UI
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar
@onready var timer = $ZombieSpawnTimer2
@onready var doorCollision =$RoomDoor/CollisionShape3D
@onready var physicalDoor = $StaticBody3D/Wall
@onready var physicalDoorCollision = $StaticBody3D/DoorCollision
@onready var physicalDoorStatic = $StaticBody3D
@onready var spider = $Spider/SpiderBoss
@onready var orbitCamera = $Spider/OrbitCamera
@onready var orbitTimer = $Spider/OrbitTimer
@onready var spotlight = $Player/SpotLight3D
@onready var spawns_outside = $spawns_outside
@onready var label = $Label
@onready var restartDialog = $Dialogs/GameLost

var playerHealth = 100
var zombie = load("res://Level3/Zombie3.1/zombie.tscn")
var instance
var zombiesSpawned=0

func _ready():
	physicalDoorCollision.disabled = true
	physicalDoor.visible = false
	#spotlight.global_transform = player.global_transform
		
	restartDialog.add_button("QUIT", true, "quit")
	restartDialog.connect("confirmed", restartLevel)
	restartDialog.connect("custom_action", quitGame)

	randomize()
	
func restartLevel():
	get_tree().reload_current_scene()
	
func quitGame(action: String):
	if action == "quit":
		get_tree().quit()
	
func _process(delta: float) -> void:
	if(spider.spiderDeath):
		timer.stop()
		if(get_tree().get_nodes_in_group("zombies").is_empty()):
			physicalDoorCollision.disabled = true
			physicalDoor.visible = false
	
func getRandomChild(parentNode):
	var randomId = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomId)
	
func _on_zombie_spawn_outside_timer_timeout() -> void:
	var spawnPoint = getRandomChild(spawns_outside).global_position
	instance = zombie.instantiate()
	instance.position = spawnPoint
	instance.scale = Vector3(0.7, 0.7, 0.7)
	print("Spawned")
	navigationRegion.add_child(instance)

func _on_zombie_spawn_timer_timeout() -> void:
	var spawnPoint = getRandomChild(spawns).global_position
	if(Level31Global.roomEntered):
		instance = zombie.instantiate()
		instance.position = spawnPoint
		instance.scale = Vector3(0.7, 0.7, 0.7)
		
		navigationRegion.add_child(instance)

func _on_player_player_been_hit() -> void:
	print("Player hit")
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
		player.dead()
		restartDialog.visible = true


func _on_door_body_entered(body: Node3D) -> void:
	if(Level31Global.completed):
		if(body.is_in_group("Player")):
			get_tree().change_scene_to_file("res://Level4/Level4.tscn")


func _on_room_door_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		Level31Global.roomEntered = true
		if(!spider.spiderDeath):
			label.text = "The Spider Holds the Key to the Exit. Eliminate it to Obtain It"
		else:
			label.text = "The key has been Obtained. Make your way to the Exit"


func _on_room_door_body_exited(body: Node3D) -> void:
	if(body.is_in_group("Player") && !spider.spiderDeath):
		spider.healthBar.visible = true
		physicalDoorCollision.disabled = false
		physicalDoor.visible = true
		doorCollision.disabled = false
		orbitTimer.start()
		orbitCamera.make_current()
		orbitCamera.startCamera = true
		print("After change: ", physicalDoorCollision.disabled)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Player")):
		if(spider.spiderDeath):
			get_tree().change_scene_to_file("res://Cutscenes/Scenes/Cutscene3.tscn")
		else:
			label.text = "You must find a Key to Unlock the Gate"


func _on_area_glitch_body_entered(body: Node3D) -> void:
	body.queue_free()


func _on_room_body_entered(body: Node3D) -> void:
	if(body.is_in_group("enemies")):
		body.add_to_group("zombies")
		print("Added")
