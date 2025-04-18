extends CharacterBody3D

var player = null
var stateMachine

@export var SPEED = 8.0
@export var ATTACK_RANGE = 1
@export var Health = 10


@export var playerPath := "/root/World/Player"
@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree


func _ready():
	player = get_node(playerPath)
	stateMachine =animationTree.get("parameters/playback")
	

func _process(delta):
	velocity = Vector3.ZERO
	
	match stateMachine.get_current_node():
		"WALK":
			navAgent.set_target_position(player.global_transform.origin)
			var nextNavPoint = navAgent.get_next_path_position()
			velocity = (nextNavPoint - global_transform.origin).normalized() * SPEED
			
			var dir = (player.global_position - global_position).normalized()
			var target_rotation = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5.0)
		
		"ATK":
			var dir = (player.global_position - global_position).normalized()
			var target_rotation = atan2(dir.x, dir.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5.0)
	
	# Condition to vheck if player is in range to attack
	animationTree.set("parameters/conditions/attack", targetInRange())
	animationTree.set("parameters/conditions/walk", !targetInRange())
	
	move_and_slide()

func targetInRange():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		print("Player Hit")
		player.hit()
		

func onZombieHit(isHeadshot: bool):
	var damage
	if isHeadshot:
		damage = 10
	else:
		damage = 5
	Health -= damage
	if(Health < 0):
		Level3Global.zombieKilled()
		animationTree.set("parameters/conditions/isDead", true)
		await get_tree().create_timer(animationTree.get_animation("DEAD").length).timeout
		queue_free()
	
	

func _on_head_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)


func _on_body_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)
