extends Label

@onready var zombieTimer = $"../ZombieSpawnTimer"
@onready var zombieTimer2 = $"../ZombieSpawnTimer2"

func _process(delta: float) -> void:
	#print(zombieTimer.wa)
	if(Level3Global.campArea):
		text = "Help Glen clear his camp from the Zombies: %s" %Level3Global.zombieCount + "/15"
	if(Level3Global.completed):
		text = "Glen can take over for now. Find the Safe House that Glen mentioned you can use for the night"
		#zombieTimer.stop()
		#zombieTimer2.start()
		#print("Timer 1:", !zombieTimer.is_stopped())
		#print("Timer 2", !zombieTimer2.is_stopped())

func _on_zombie_spawn_timer_timeout() -> void:
	print(zombieTimer)
	print("Time out")
