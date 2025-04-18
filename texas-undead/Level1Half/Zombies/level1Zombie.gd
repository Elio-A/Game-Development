extends CharacterBody3D

signal zombie_died

var player = null
var stateMachine
@export var SPEED = 4.0
@export var ATTACK_RANGE = 1
@export var Health = 10

@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		push_error("Player node not found! Make sure your Player is in the 'Player' group.")
		return
	stateMachine = animationTree.get("parameters/playback")

func _process(delta):
	if not player:
		return

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

	# Condition to check if player is in range to attack
	animationTree.set("parameters/conditions/attack", targetInRange())
	animationTree.set("parameters/conditions/walk", !targetInRange())

	move_and_slide()

func targetInRange():
	return player and global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitFinished():
	if player and global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		print("Player Hit")
		player.hit()

func onZombieHit(isHeadshot: bool):
	var damage = 10 if isHeadshot else 5
	Health -= damage
	if Health < 0:
		zombieDied()
		
func zombieDied():
	animationTree.set("parameters/conditions/isDead", true)
	await get_tree().create_timer(animationTree.get_animation("DEAD").length).timeout
	emit_signal("zombie_died")
	queue_free()
	return true

func _on_head_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)

func _on_body_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("HEADHIT")
		onZombieHit(true)
