extends Node2D

signal level_ended
signal dialogue_started(title : String)

func _ready():
	await(get_tree().create_timer(0.1).timeout)
	start_dialogue("Story_1_1")

func end_level():
	emit_signal("level_ended")

func start_dialogue(dialogue_title : String):
	emit_signal("dialogue_started", dialogue_title)


func _on_exit_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		emit_signal("level_ended")
