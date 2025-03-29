extends Node3D

@onready var light := $"."

@export var min_delay := 2.0
@export var max_delay := 6.0
@export var flicker_strength := 5.0
@export var flicker_speed := 0.05
@export var flicker_times := 5

func _ready():
	randomize()
	flicker_loop()

func flicker_loop():
	flicker_once()
	await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
	flicker_loop()

func flicker_once():
	for i in flicker_times:
		light.light_energy = 0.0
		await get_tree().create_timer(flicker_speed).timeout
		light.light_energy = flicker_strength
		await get_tree().create_timer(flicker_speed).timeout
