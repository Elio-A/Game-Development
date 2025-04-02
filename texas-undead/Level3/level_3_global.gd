extends Node

var zombieCount = 0

var campArea: bool
var completed = false
var counterOn = true
var timer = 1.5

func _process(delta: float) -> void:
	if(zombieCount == 5):
		completed = true
		counterOn = false
		
	if(completed):
		timer = 0.3
		

func zombieKilled():
	if(counterOn && campArea):
		zombieCount += 1
	
