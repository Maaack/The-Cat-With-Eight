extends BaseLevel

@export var floating_squeak_scene : PackedScene
@export var squeak_offset : Vector2 = Vector2.ZERO

var saw_hawk_flag : bool = false
var saw_mouse_flag : bool = false
var mouse_catches : int = 0
var mouse_played_dead_flag : bool = false
var dropped_trophy_flag : bool = false
var is_by_door : bool = false
var mouse_hiding_spots : Array[Node2D] = []
var meows_by_door : int = 0
var tried_meowing_while_carrying_flag : bool = false
var meow_hint_one : bool = false
var meow_hint_two : bool = false

func _on_mouse_eating_area_2d_body_entered(body):
	if body.is_in_group(Constants.MOUSE_GROUP):
		if not body.fleeing:
			body.action_vector = Vector2.ZERO

func _on_saw_hawk_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		if saw_hawk_flag:
			return
		saw_hawk_flag = true
		start_dialogue("Story_3_3")

func _on_saw_mouse_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		if saw_mouse_flag:
			return
		saw_mouse_flag = true
		start_dialogue("Story_3_4")

func _on_mouse_left_hiding_spot():
	$HidingTimer.stop()
	await(get_tree().create_timer(0.5).timeout)
	for hiding_spot in mouse_hiding_spots:
		hiding_spot.enable_spot()

func _on_mouse_catch_area_2d_body_entered(body):
	if body.is_in_group(Constants.MOUSE_GROUP):
		if not is_instance_valid(body) or body.in_bush:
			return
		mouse_catches += 1
		body.set_collision_layer_value(2, false)
		match(mouse_catches):
			1:
				start_dialogue("Story_3_5")
			2:
				start_dialogue("Story_3_6")
			3:
				start_dialogue("Story_3_7")
			4:
				start_dialogue("Story_3_9")
			5:
				start_dialogue("Story_3_10")
		await(DialogueManager.dialogue_ended)
		if mouse_catches < 5:
			body.catapult()
			if mouse_catches >= 3:
				body.play_dead()
		else:
			$Tiger.carrying_carcass = true
			body.queue_free()
			await(get_tree().create_timer(2, false).timeout)
			start_dialogue("Not_Too_Heavy_To_Carry")

func _on_mouse_played_dead():
	if mouse_played_dead_flag:
		return
	mouse_played_dead_flag = true
	start_dialogue("Story_3_8")

func _on_mouse_squeaked(bush_position : Vector2):
	spawn_floating_sprite(bush_position + squeak_offset, floating_squeak_scene)

func _ready():
	for child in get_children():
		if child.is_in_group(Constants.HIDING_BUSH_GROUP):
			child.connect("mouse_squeaked", _on_mouse_squeaked)
			mouse_hiding_spots.append(child)


func _on_drop_trophy_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		if dropped_trophy_flag or not body.carrying_carcass:
			return
		dropped_trophy_flag = true
		body.carrying_carcass = false
		start_dialogue("Left_Trophy_At_Door")
		$MeowTimer.start()

func _on_meow_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = true

func _on_meow_area_2d_body_exited(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = false

func _start_level_ending():
	start_dialogue("Story_3_End")
	await(DialogueManager.dialogue_ended)
	var game_ui = get_tree().current_scene
	game_ui.transition_close()
	await(game_ui.transition_finished)
	$Tiger.set_physics_process(false)
	$MainCamera2D.enabled = false
	$ProudKittySprite2D/Camera2D.enabled = true
	game_ui.transition_open()
	await(game_ui.transition_finished)
	start_dialogue("Story_3_End_2")
	await(DialogueManager.dialogue_ended)
	game_ui.transition_close()
	await(game_ui.transition_finished)
	end_level()

func tiger_meowed(tiger_position : Vector2):
	super.tiger_meowed(tiger_position)
	if is_instance_valid($Mouse):
		$Mouse.extra_aware()
	if is_by_door and dropped_trophy_flag:
		meows_by_door += 1
		if meows_by_door > 2:
			_start_level_ending()
			return
		$MeowTimer.start()

func _on_mouse_entered_hiding_spot():
	$HidingTimer.start()

func _on_hiding_timer_timeout():
	start_dialogue("Leave_The_Bush_Alone")

func tiger_meow_tried():
	if $Tiger.carrying_carcass:
		if tried_meowing_while_carrying_flag:
			return
		tried_meowing_while_carrying_flag = true
		start_dialogue("No_Meow_While_Carrying")

func _on_meow_timer_timeout():
	if not meow_hint_one:
		meow_hint_one = true
		start_dialogue("Need_To_Get_Attention")
	elif not meow_hint_two:
		meow_hint_two = true
		start_dialogue("Need_To_Meow_Again")
