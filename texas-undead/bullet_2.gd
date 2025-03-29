extends Node3D

const Speed = 35

@onready var bulletMesh = $MeshInstance3D
@onready var rayCast = $RayCast3D
@onready var collisionParticles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -Speed) * delta
	if rayCast.is_colliding():
		bulletMesh.visible = false
		collisionParticles.emitting = true
		await get_tree().create_timer(0.2).timeout
		queue_free() #Clearing the bullet after a second timer after collision


func _on_no_hit_bullet_timer_timeout() -> void:
	queue_free()
