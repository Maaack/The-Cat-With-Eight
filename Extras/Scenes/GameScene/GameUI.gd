extends Control

@onready var action_names = AppSettings.get_filtered_action_names()
@onready var transition = $Transition

var balloon_packed_scene : PackedScene = preload("res://Scenes/DialogueBalloon/Balloon.tscn")

var balloon

func _on_dialogue_started(title : String):
	balloon = balloon_packed_scene.instantiate()
	get_tree().current_scene.add_child(balloon)
	get_tree().paused = true
	balloon.start(load("res://Resources/story.dialogue"), title)
	await(DialogueManager.dialogue_ended)
	balloon = null
	get_tree().paused = false

func _on_base_level_dialogue_started(title):
	_on_dialogue_started(title)

func _on_base_level_level_ended():
	SceneLoader.load_scene("res://Scenes/LevelLoader/LevelLoader.tscn")

func _clear_level():
	var viewport_children : Array[Node] = %SubViewport.get_children()
	for child in viewport_children:
		child.queue_free()

func _attach_level(level_resource : Resource):
	var instance = level_resource.instantiate()
	instance.connect("dialogue_started", _on_dialogue_started)
	instance.connect("level_ended", _load_next_level)
	%SubViewport.call_deferred("add_child", instance)

func _load_current_level():
	_clear_level()
	var level_file = %LevelLoader.get_current_level_file()
	SceneLoader.load_scene(level_file, true)
	await(SceneLoader.scene_loaded)
	_attach_level(SceneLoader.get_resource())

func _load_next_level():
	%LevelLoader.increment_level()
	_load_current_level()

func _ready():
	_load_current_level()
