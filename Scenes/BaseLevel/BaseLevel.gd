extends Node2D
class_name BaseLevel

signal level_ended
signal dialogue_started(title : String)

@export var opening_dialogue_title : String

func _ready():
	await(get_tree().create_timer(0.1).timeout)
	start_dialogue(opening_dialogue_title)

func end_level():
	emit_signal("level_ended")

func start_dialogue(dialogue_title : String):
	emit_signal("dialogue_started", dialogue_title)

func _on_exit_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		end_level()
