extends Camera3D

@export var target : Node3D 

@onready var orbitTimer = $"../OrbitTimer"
@onready var player = $"../../Player"
@onready var spider = $"../SpiderBoss"

var orbiting = true
var startCamera = false
var speed = PI/8
var offset 
var angle = 0

func _ready(): 
	offset = global_position - target.global_position;

func _process(delta):
	if(orbiting):
		if(startCamera):
			angle+= speed*delta 
			angle = fmod(angle, 2*PI) 
			
			var rotated_offset= offset.rotated(Vector3.UP, angle)
			global_position = target.global_position + rotated_offset
			#position = offset.rotated(Vector3.UP, angle) + target.position 
			look_at(target.global_position, Vector3.UP)
	else:
		player.camera.make_current()
		spider.move = true
		
func _on_orbit_timer_timeout() -> void:
	orbiting = false
