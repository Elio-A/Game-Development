extends Node


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Cutscenes/Scenes/Cutscene1.tscn")



func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/OptionsMenu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit(1)
