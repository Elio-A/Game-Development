extends CharacterBody3D

@export var speed = 10
@export var gravity = -9
@export var jumpForce = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#Getting input direction:
	var inputDirection = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(inputDirection.x, 0, inputDirection.y)).normalized()
	
	#Applying Gravity:
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#Jump:
	if Input.is_action_pressed("Jump") and is_on_floor():
		velocity.y = jumpForce
		
	#Set Horizontal Velocity:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
