extends FogVolume

var target_density = 1.0  # Full fog at start
var fade_speed = 0.5  # Speed of fog disappearing

func _process(delta):
	if material:
		var current_density = material.get("density")  # Use get() instead
		material.set("density", lerp(current_density, target_density, fade_speed * delta))  # Use set() instead
