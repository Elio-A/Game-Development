extends Label

@onready var timer = $"../LevelTimer"
var time_left := 120 # 2 minutes in seconds

func _ready():
	update_label()
	timer.start()

func update_label():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	text = "Time Remaining: %02d:%02d" % [minutes, seconds]


func _on_level_timer_timeout() -> void:
	time_left -= 1
	if time_left < 0:
		time_left = 0
	timer.start() # restart timer every second
	update_label()
	if time_left == 0:
		get_tree().change_scene_to_file("res://Level2/Basement/level_basment.tscn")
