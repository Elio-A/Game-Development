extends Node3D

@onready var hitRectangle = $UI/HitScreen

func _ready() -> void:
	hitRectangle.visible = false
	
func _process(delta: float) -> void:
	pass

func _on_player_player_been_hit() -> void:
	hitRectangle.visible = true
	await get_tree().create_timer(0.3).timeout
	hitRectangle.visible = false
