extends CharacterBody3D

var player = null
const speed = 4

@export var playerPath : NodePath

@onready var navigationAgent = $NavigationAgent3D

func _ready():
	player = get_node(playerPath)

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	#Processing Navegation:
	navigationAgent.set_target_position(player.global_transform.origin)
	var nextLocation = navigationAgent.get_next_path_position()
	velocity = (nextLocation - global_transform.origin).normalized()
	
	#Zombie looking at player
	look_at(Vector3(player.global_position.x, player.global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide()
