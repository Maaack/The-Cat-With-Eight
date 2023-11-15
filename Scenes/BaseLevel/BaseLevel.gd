extends Node2D
class_name BaseLevel

signal level_ended
signal dialogue_started(title : String)

@export var floating_meow_scene : PackedScene
@export var meow_offset : Vector2 = Vector2.ZERO
@export var opening_dialogue_title : String

func _ready():
	await(get_tree().create_timer(0.1, false).timeout)
	if not opening_dialogue_title.is_empty():
		start_dialogue(opening_dialogue_title)

func end_level():
	emit_signal("level_ended")

func start_dialogue(dialogue_title : String):
	emit_signal("dialogue_started", dialogue_title)

func _on_exit_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		end_level()

func spawn_floating_sprite(sprite_position : Vector2, floating_sprite_scene : PackedScene):
	var floating_sprite_instance = floating_sprite_scene.instantiate()
	call_deferred("add_child", floating_sprite_instance)
	floating_sprite_instance.position = sprite_position
	return floating_sprite_instance

func cat_meowed(cat_position : Vector2):
	spawn_floating_sprite(cat_position + meow_offset, floating_meow_scene)

func tiger_meowed(tiger_position : Vector2):
	cat_meowed(tiger_position)

func _on_tiger_meowed():
	tiger_meowed($Tiger.position)

func tiger_jumped():
	pass

func _on_tiger_jumped():
	tiger_jumped()

func tiger_meow_tried():
	pass

func tiger_jump_tried():
	pass

func _on_tiger_jump_tried():
	tiger_jump_tried()

func _on_tiger_meow_tried():
	tiger_meow_tried()
