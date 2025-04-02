extends VideoStreamPlayer


func _on_finished() -> void:
	get_tree().change_scene_to_file("res://ground.tscn")
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("Escape"):
		get_tree().change_scene_to_file("res://ground.tscn")
