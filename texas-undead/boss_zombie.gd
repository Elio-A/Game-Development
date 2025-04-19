extends CharacterBody3D

var player = null
var stateMachine

const SPEED = 8.0
const ATTACK_RANGE = 50
var Health = 200


@export var playerPath := "/root/World/Player"
@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree
@onready var healthBar = $ZombieBossHealthBar


func _ready():
	healthBar.visible = false
	player = get_node(playerPath)
	stateMachine =animationTree.get("parameters/playback")
	

func _process(delta):
	healthBar.value = Health
	velocity = Vector3.ZERO
	match stateMachine.get_current_node():
		"BossZombie2_ZombieRunning":
			navAgent.set_target_position(player.global_transform.origin)
			var next_nav_point = navAgent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"Zombieneckbite":
			look_at(Vector3(player.global_position.x, global_position.y, global_position.z), Vector3.UP)
		"Zombieidle":
			animationTree.set("parameters/conditions/Zombieidle", targetInRange())
	
	# Condition to vheck if player is in range to attack
	animationTree.set("parameters/conditions/attack", targetInRange())
	animationTree.set("parameters/conditions/scream", !targetInRange())
	
	move_and_slide()

func targetInRange():
	print(global_position.distance_to(player.global_position))
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.5:
		print("Player Hit")
		player.hit()
		

func onZombieHit(isHeadshot: bool):
	var damage = 10
	if(Health < 0):
		Level3Global.zombieKilled()
		animationTree.set("parameters/conditions/dead", true)
		await get_tree().create_timer(animationTree.get_animation("Zombiedying").length).timeout
		queue_free()
	
	

func _on_head_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)


func _on_body_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
	
