extends Node3D

@onready var hitRectangle = $UI/HitScreen
@onready var restartDialog = $Dialogs/GameLost
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar

var zombies = []

var playerHealth = 100

func _ready() -> void:
	hitRectangle.visible = false
	healthBar.visible = true
	
	#Restart dialog functionality:
	restartDialog.add_button("QUIT", true, "quit")
	restartDialog.connect("confirmed", restartLevel)
	restartDialog.connect("custom_action", quitGame)
	
	#Getting all zombies in scene
	zombies = get_tree().get_nodes_in_group("Zombie")
	
	for zombie in zombies:
		zombie.connect("zombieHit", onZombieHit)
		zombie.connect("zombieDied", onZombieDead)
	
func _process(_delta: float) -> void:
	pass

func _on_player_player_been_hit() -> void:
	#Hit screen
	hitRectangle.visible = true
	await get_tree().create_timer(0.3).timeout
	hitRectangle.visible = false
	
	#Damage dealing:
	playerHealth -= 10
	#print("The player health is now: " + playerHealth)
	
	healthBar.value -= 10
	
	if playerHealth <= 0:
		print("Player dead!")
		player.dead()
		restartDialog.visible = true
		
func restartLevel():
	get_tree().reload_current_scene()
		
func quitGame(action: String):
	if action == "quit":
		get_tree().quit()

func _on_crypt_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		moveToNextLevel()
		
func moveToNextLevel():
	pass #For now
	#Replace player with scene 2
	get_tree().change_scene_to_file("res://Level2/Level2.tscn")
		

func onZombieHit(zombie: CharacterBody3D, isHeadshot: bool):
	var damage
	if isHeadshot:
		damage = 10
	else:
		damage = 5
	
	zombie.takeDamage(damage)
	
func onZombieDead(zombie: CharacterBody3D):
	zombies.erase(zombie)
