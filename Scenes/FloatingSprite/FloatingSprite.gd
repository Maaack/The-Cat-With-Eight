extends Node2D

@export var velocity : Vector2 = Vector2(0, -1)

func _process(delta):
	position += delta * velocity
