extends CharacterBody3D

var player = null
var state_machine
const SPEED = 6.0
const ATTACK_RANGE = 3.5
var Health = 150
var move: bool = false
var spiderDeath = false


@export var player_path := "/root/World/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var healthBar = $SpiderHealthBar
	
func _ready() -> void:
	healthBar.visible = false
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	
func _process(delta: float) -> void:
	healthBar.value = Health
	velocity = Vector3.ZERO
	match state_machine.get_current_node():
		"RUN":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"ATK":
			look_at(Vector3(player.global_position.x, global_position.y, global_position.z), Vector3.UP)
		"IDLE":
			anim_tree.set("parameters/conditions/Idle", _target_in_range())
	
	if(move):
		anim_tree.set("parameters/conditions/attack", _target_in_range())
		anim_tree.set("parameters/conditions/run", !_target_in_range())
		move_and_slide()
	
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.5:
		print("Player Hit")
		player.hit()
		
func onSpiderHit(isHeadshot: bool):
	var damage
	if isHeadshot:
		damage = 10
	else:
		damage = 5
	Health -= damage
	print(Health)
	if(Health <= 0):
		Level31Global.zombieKilled()
		anim_tree.set("parameters/conditions/dead", true)
		await get_tree().create_timer(anim_tree.get_animation("DEAD").length).timeout
		spiderDeath = true
		#queue_free()
	else:
		anim_tree.set("parameters/conditions/Hit", true)
		await get_tree().create_timer(anim_tree.get_animation("HIT").length).timeout
		anim_tree.set("parameters/conditions/Hit", false)
		anim_tree.set("parameters/conditions/run", true)


func on_body_entered(body: Node3D) -> void:
	if(body.is_in_group("Bullet")):
		onSpiderHit(false)


func _on_eye_entered(body: Node3D) -> void:
	if(body.is_in_group("Bullet")):
		onSpiderHit(true)
