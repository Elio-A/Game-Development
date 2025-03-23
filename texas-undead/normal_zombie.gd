extends CharacterBody3D

var player = null
var stateMachine

const speed = 4
const ATTACK_RANGE = 2

@export var playerPath : NodePath

@onready var navigationAgent = $NavigationAgent3D
@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree


func _ready():
	player = get_node(playerPath)
	
	var animation = animationPlayer.get_animation("Walking0")
	animation.loop_mode = Animation.LOOP_LINEAR
	
	stateMachine = animationTree.get("parameters/playback")

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	match stateMachine.get_current_node():
		"Walking0":
			#Processing Navegation:
			navigationAgent.set_target_position(player.global_transform.origin)
			var nextLocation = navigationAgent.get_next_path_position()
			velocity = (nextLocation - global_transform.origin).normalized()
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"ZombieAttack0":
			#Zombie looking at player
			look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)

	#Animation Condition:
	animationTree.set("parameters/conditions/isAttack", playerInRange())
	
	move_and_slide()

func playerInRange():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func hitComplete():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1:
		player.hit()

#Not working, do not know why?
func _on_body_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		print("Headshot!")
