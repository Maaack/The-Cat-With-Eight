extends BaseLevel

const CHATTER_OFFSET = 10.0
var meow_counter : int = 0
var story_flag_1_2 : bool = false
var family_talking : bool = true :
	set(value):
		family_talking = value
		if is_inside_tree():
			$ChatterSprite2D.visible = family_talking
var is_by_door : bool = false
var tried_wrong_way : bool = false
var tried_jumping : bool = false
var tried_jumping_by_door : bool = false
var tried_stronger_jumping : bool = false
var tried_sprinting : bool = false
var meows_away_from_door : int = 0
var meowed_away_from_door : bool = false
var power_raised : bool = false
var longer_chatting_pause : bool = false
var consecutive_unheard_meows : int = 0

func _on_move_instructions_timer_timeout():
	$MoveInstructions.show()

func _on_meow_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = true
		$Tiger/EnergyMeter.show()
		if $MeowTimer.is_stopped():
			$MeowTimer.start()

func _on_meow_area_2d_body_exited(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = false

func _on_meow_timer_timeout():
	$MeowInstructions.show()

func _start_level_ending():
	$SilentTimer2.stop()
	await(get_tree().create_timer(2.5, false).timeout)
	start_dialogue("Story_1_3")
	await(DialogueManager.dialogue_ended)
	var game_ui = get_tree().current_scene
	game_ui.transition_close()
	await(game_ui.transition_finished)
	$Tiger.set_physics_process(false)
	$MainCamera2D.enabled = false
	$SleepingKittySprite2D/Camera2D.enabled = true
	game_ui.transition_open()
	await(game_ui.transition_finished)
	start_dialogue("Story_1_4")
	await(DialogueManager.dialogue_ended)
	game_ui.transition_close()
	await(game_ui.transition_finished)
	end_level()

func _check_meow_by_door():
	if not is_by_door:
		meows_away_from_door += 1
		if meows_away_from_door >= 3 and not meowed_away_from_door:
			meowed_away_from_door = true
			await(get_tree().create_timer(1.5, false).timeout)
			start_dialogue("Cant_Hear_Me_Here")
		return
	if meow_counter > 0:
		if family_talking:
			consecutive_unheard_meows += 1
		else:
			consecutive_unheard_meows = 0
		family_talking = false
	meow_counter += 1
	if not $SilentTimer2.is_stopped():
		_start_level_ending()
	if not $SilentTimer1.is_stopped():
		$SilentTimer1.stop()
		$SilentTimer2.start()
	else:
		$SilentTimer1.start()
	if meow_counter >= 3 and not story_flag_1_2:
		story_flag_1_2 = true
		await(get_tree().create_timer(2.5, false).timeout)
		start_dialogue("Story_1_2")
		await(DialogueManager.dialogue_ended)
		$Tiger.max_energy += 1
		power_raised = true
	elif story_flag_1_2 and consecutive_unheard_meows > 0 and consecutive_unheard_meows % 8 == 0:
		await(get_tree().create_timer(1.0, false).timeout)
		start_dialogue("Meow_Twice_In_A_Row")
	elif story_flag_1_2 and consecutive_unheard_meows > 0 and consecutive_unheard_meows % 4 == 0:
		await(get_tree().create_timer(1.0, false).timeout)
		start_dialogue("Need_To_Wait")
	

func tiger_meowed(cat_position):
	super.tiger_meowed(cat_position)
	_check_meow_by_door()

func _on_silent_timer_1_timeout():
	family_talking = true

func _on_silent_timer_2_timeout():
	family_talking = true
	if not longer_chatting_pause:
		longer_chatting_pause = true
		start_dialogue("Stopped_Chatting_Longer")

func _ready():
	$Tiger/EnergyMeter.hide()

func _on_wrong_way_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		if not tried_wrong_way:
			tried_wrong_way = true
			start_dialogue("Wrong_Way")

func tiger_jump_tried():
	if not tried_jumping:
		tried_jumping = true
		start_dialogue("Too_Weak_To_Jump")
		await(DialogueManager.dialogue_ended)
	if is_by_door and not tried_jumping_by_door:
		tried_jumping_by_door = true
		start_dialogue("Cant_Jump_Up_Step")
		await(DialogueManager.dialogue_ended)
	if power_raised and not tried_stronger_jumping:
		tried_stronger_jumping = true
		start_dialogue("Still_Cant_Jump")

func _on_chatter_sprite_2d_frame_changed():
	var random_angle = randf_range(-2*PI, 2*PI)
	var random_direction := Vector2.from_angle(random_angle)
	var main_camera_offset = min(0, $MainCamera2D.get_target_position().x-450)
	$ChatterSprite2D.position = $ChatterMarker2D.position + random_direction * CHATTER_OFFSET
	$ChatterSprite2D.position.x += main_camera_offset
	#$ChatterSprite2D.rotation = randf_range(-0.1*PI, 0.1*PI)

func _on_instructions_area_2d_body_exited(body):
	$MoveInstructionsTimer.stop()

func _on_instructions_area_2d_2_body_exited(body):
	$MoveInstructionsTimer2.stop()

func _on_tiger_sprint_tried():
	if not tried_sprinting:
		tried_sprinting = true
		start_dialogue("Too_Weak_To_Run")
