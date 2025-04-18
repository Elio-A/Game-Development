extends Node

var zombieCount = 0

var campArea: bool
var completed = false
var counterOn = true
var timer = 1.5

func _process(delta: float) -> void:
	if(zombieCount == 15):
		completed = true
		counterOn = false
		
	if(completed):
		timer = 0.3
		

func zombieKilled():
	print(counterOn)
	print(campArea)
	if(counterOn && campArea):
		print("Zombie killed inside the camp")
		zombieCount += 1
	
