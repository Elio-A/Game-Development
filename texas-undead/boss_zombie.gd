extends CharacterBody3D

var player = null
var stateMachine

const SPEED = 300
const ATTACK_RANGE = 15
var Health = 100


@export var playerPath := "/root/World2/Player"
@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree
@onready var healthBar = $ZombieBossHealthBar
var move
@onready var Finish = $Finish
var killed = false


func _ready():
	move = false
	healthBar.visible = true
	healthBar.value = 100
	player = get_node(playerPath)
	stateMachine =animationTree.get("parameters/playback")
	

func _process(delta):
	healthBar.value = Health
	velocity = Vector3.ZERO

	match stateMachine.get_current_node():
		"BossZombie2_ZombieRunning":
			# 1. Look at the player
			var look_pos = player.global_position
			look_pos.y = global_position.y  # Maintain own Y
			look_at(look_pos, Vector3.UP)

			# 2. Move forward in facing direction (negative Z axis in Godot 3D)
			velocity = -transform.basis.z * SPEED

		"Zombieneckbite":
			var look_pos = player.global_position
			look_pos.y = global_position.y
			look_at(look_pos, Vector3.UP)

		"Zombieidle":
			animationTree.set("parameters/conditions/Zombieidle", targetInRange())
			


	if(move):
		# Update animation conditions
		animationTree.set("parameters/conditions/attack", targetInRange())
		animationTree.set("parameters/conditions/run", !targetInRange())

		move_and_slide()


func targetInRange():
	#print(global_position.distance_to(player.global_position))
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 10:
		print("Player Hit")
		player.hit()
		

func onZombieHit(isHeadshot: bool):
	Health -= 5
	if(Health < 0):
		Level3Global.zombieKilled()
		animationTree.set("parameters/conditions/dead", true)
		await get_tree().create_timer(animationTree.get_animation("Zombiedying").length).timeout
		Level31Global.killed = true
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HIT")
		onZombieHit(true)
	


func _on_entered(body: Node3D) -> void:
	print(body.get_groups())
	if(body.is_in_group("Player")):
		Level31Global.health = true
		move = true
