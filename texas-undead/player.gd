extends CharacterBody3D

@export var speed = 10
@export var gravity = -20
@export var jumpForce = 5

const sensitivity = 0.005
const runSpeed = 15
const normSpeed = 10
#Camera/Head Bob
const bobFreq = 1 #How often the footsteps happen
const bobAmp = 0.20 #How far up and down the camera will go
var sinVal = 0.8

var bullet = load("res://bullet_2.tscn")
var instance

signal playerHit

@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var gun = $Head/Camera3D/Revolver/AnimationPlayer
@onready var barrel = $Head/Camera3D/Revolver/RayCast3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Making mouse not visible:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#Head movement left and right
		head.rotate_y(-event.relative.x * sensitivity)
		
		#Head movement up and down
		var verticalInput = -event.relative.y * sensitivity
		
		camera.rotation.x += verticalInput
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#Getting input direction:
	var inputDirection = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	
	#Applying Gravity:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#Jump:
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jumpForce
		
	#Running:
	if Input.is_action_pressed("Run"):
		speed = runSpeed
	else:
		speed = normSpeed
	
	#Set Horizontal Velocity:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	#Head Bop:
	sinVal += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = headBob(sinVal)
	
	#Gun Animation:
	if Input.is_action_pressed('Shoot'):
		if !gun.is_playing():
			gun.play("Shoot")
			instance = bullet.instantiate()
			instance.position = barrel.global_position
			instance.transform.basis = barrel.global_transform.basis
			get_parent().add_child(instance)
			
	move_and_slide()

#Headbob handling:
func headBob(time) ->Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFreq) * bobAmp
	return pos
