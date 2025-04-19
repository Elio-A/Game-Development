extends Node3D

@onready var hitRectangle = $UI
@onready var player = $Player
@onready var healthBar = $Player/Head/Camera3D/HealthBar
@onready var restartDialog = $Dialogs/GameLost
@onready var boss = $BossZombie
@onready var finish = $Finish
@onready var health = $BossZombie/ZombieBossHealthBar

var playerHealth = 100

func _ready() -> void:
	restartDialog.add_button("QUIT", true, "quit")
	restartDialog.connect("confirmed", restartLevel)
	restartDialog.connect("custom_action", quitGame)
	health.visible = false

func _process(delta: float) -> void:
	if(Level31Global.health && !Level31Global.killed):
		health.visible = true
		
	if(Level31Global.killed):
		finish.visible = true
		

func restartLevel():
	get_tree().reload_current_scene()
	
func quitGame(action: String):
	if action == "quit":
		get_tree().quit()
		
func _on_player_player_been_hit() -> void:
	# Hit screen
	hitRectangle.visible = true
	hitRectangle.modulate.a = 1.0 # Fully visible

	var tween = get_tree().create_tween()
	tween.tween_property(hitRectangle, "modulate:a", 0.0, 1)
	await tween.finished

	hitRectangle.visible = false

	
	#Damage dealing:
	playerHealth -= 20
	healthBar.value -= 20
	
	if playerHealth <= 0:
		player.dead()
		restartDialog.visible = true


func _on_confirmed() -> void:
	get_tree().quit()

func dead():
	finish.visible = true
