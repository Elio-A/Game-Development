extends CharacterBody3D

var player = null
var stateMachine

const SPEED = 300
const ATTACK_RANGE = 15
var Health = 200


@export var playerPath := "/root/World/Player"
@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree
@onready var healthBar = $ZombieBossHealthBar


func _ready():
	healthBar.visible = true
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

	# Update animation conditions
	animationTree.set("parameters/conditions/attack", targetInRange())
	animationTree.set("parameters/conditions/run", !targetInRange())

	move_and_slide()


func targetInRange():
	print(global_position.distance_to(player.global_position))
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 10:
		print("Player Hit")
		player.hit()
		

func onZombieHit(isHeadshot: bool):
	var damage = 10
	if(Health < 0):
		Level3Global.zombieKilled()
		animationTree.set("parameters/conditions/dead", true)
		await get_tree().create_timer(animationTree.get_animation("Zombiedying").length).timeout
		queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HIT")
		onZombieHit(true)
	
