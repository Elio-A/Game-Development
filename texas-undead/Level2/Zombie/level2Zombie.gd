extends CharacterBody3D

signal zombieHit(zombie, isHeadshot)
signal zombieDied(zombie)

var player = null
var stateMachine

const speed = 4
const ATTACK_RANGE = 2

const MAX_HEALTH = 50
var zombieHealth = MAX_HEALTH

@export var playerPath : NodePath

@onready var navigationAgent = $NavigationAgent3D
@onready var animationPlayer = $Sketchfab_Scene2/AnimationPlayer
@onready var animationTree = $Sketchfab_Scene2/AnimationTree


func _ready():
	player = get_node(playerPath)
	
	var animation = animationPlayer.get_animation("IDLE")
	animation.loop_mode = Animation.LOOP_LINEAR
	
	stateMachine = animationTree.get("parameters/playback")

func _process(_delta: float) -> void:
	if animationTree.get("parameters/conditions/isDead"):
		return #As to not process movements when zombie dies
	
	velocity = Vector3.ZERO
	
	match stateMachine.get_current_node():
		"WALK":
			#Processing Navegation:
			navigationAgent.set_target_position(player.global_transform.origin)
			var nextLocation = navigationAgent.get_next_path_position()
			velocity = (nextLocation - global_transform.origin).normalized()
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"ATK":
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

#Not working, do not know why

func _on_zombie_body_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		emit_signal("zombieHit", self, false) #Body shot

func _on_head_area_entered(body: Node3D) -> void:
	if body.is_in_group("Bullet"):
		emit_signal("zombieHit", self, true) #Head shot
		
func takeDamage(amount: int):
	zombieHealth -= amount
	if zombieHealth <= 0:
		dead()
		
func dead():
	animationTree.set("parameters/conditions/isDead", true)
	await get_tree().create_timer(animationPlayer.get_animation("ZombieDeath0").length).timeout
	despawn()

func despawn():
	print("ZOmbie died!")
	emit_signal("zombieDied", self)
	queue_free()
