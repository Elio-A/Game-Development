extends Node3D
@onready var spawns = $Spawns
@onready var navigationRegion = $NavigationRegion3D

@onready var hitRectangle = $UI
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar
@onready var restartDialog = $Dialogs/GameLost

var playerHealth = 100

var zombie = load("res://Level2/Zombie/zombie.tscn")
var instance
func _ready():
	randomize()
	restartDialog.add_button("QUIT", true, "quit")
	restartDialog.connect("confirmed", restartLevel)
	restartDialog.connect("custom_action", quitGame)

func restartLevel():
	get_tree().reload_current_scene()
	
func quitGame(action: String):
	if action == "quit":
		get_tree().quit()

func getRandomChild(parentNode):
	var randomId = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomId)

func _on_zombie_spawn_timer_timeout() -> void:
	var spawnPoint = getRandomChild(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawnPoint
	instance.scale = Vector3(0.7, 0.7, 0.7)
	navigationRegion.add_child(instance)

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


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("Something entered: ", body.name)
	if body.is_in_group("Player"):
		print("Player entered!")
		get_tree().change_scene_to_file("res://Level3.1.tscn")#CHECK!!!
