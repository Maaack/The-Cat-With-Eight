extends Node2D

func _ready():
	await(get_tree().create_timer(0.1).timeout)
	DialogueManager.show_example_dialogue_balloon(load("res://Resources/story.dialogue"), "Story_1_1")
