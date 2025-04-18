extends Node3D

var zombie = load("res://Level1Half/Zombies/zombie.tscn")
var instance
var playerHealth = 100
var zombiesKilled = 0

@onready var spawns = $Spawner
@onready var navigationRegion = $NavigationRegion3D
@onready var healthBar = $Player/Head/Camera3D/HealthBar
@onready var hitRectangle = $UI
@onready var player = $Player
@onready var restartDialog = $Dialogs/GameLost
@onready var hospitalDoors = $NavigationRegion3D/HospitalBuilding/HospitalBuilding/Area3D
@onready var zombiesKillCounter = $ZombieKillCounter

func _ready():
	hospitalDoors.monitoring = false
	
	restartDialog.add_button("QUIT", true, "quit")
	restartDialog.connect("confirmed", restartLevel)
	restartDialog.connect("custom_action", quitGame)


func restartLevel():
	get_tree().reload_current_scene()
		
func quitGame(action: String):
	if action == "quit":
		get_tree().quit()
		
func _on_hospital_doors_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://Cutscenes/Scenes/Cutscene2.tscn")
		
func getRandomChild(parentNode):
	var randomId = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomId)

func _on_zombie_spawn_timer_timeout() -> void:
	var spawnPoint = getRandomChild(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawnPoint
	instance.scale = Vector3(0.7, 0.7, 0.7)
	navigationRegion.add_child(instance)
	instance.zombie_died.connect(_on_zombie_died)

func _on_zombie_died():
	zombiesKilled += 1
	zombiesKillCounter.text = "Zombies killed: %d/20" % zombiesKilled
	if zombiesKilled >= 20:
		openDoors()

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
		player.dead()
		restartDialog.visible = true

func openDoors():
	hospitalDoors.monitoring = true
