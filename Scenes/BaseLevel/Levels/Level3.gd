extends BaseLevel

@export var mouse_hiding_spots : Array[Node2D] = []


func _on_mouse_left_hiding_spot():
	await(get_tree().create_timer(0.5).timeout)
	for hiding_spot in mouse_hiding_spots:
		hiding_spot.enable_spot()
