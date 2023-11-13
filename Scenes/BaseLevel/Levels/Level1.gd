extends BaseLevel

var meow_counter : int = 0
var story_flag_1_2 : bool = false
var family_talking : bool = true
var is_by_door : bool = false

func _on_move_instruction_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		$MoveInstructionsTimer.start()

func _on_move_instructions_timer_timeout():
	$MoveInstructionsSprite2D.show()

func _on_meow_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = true
		$MeowTimer.start()

func _on_meow_area_2d_body_exited(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		is_by_door = false
		$MeowTimer.stop()

func _on_meow_timer_timeout():
	$MeowSprite2D.show()

func _check_meow_by_door():
	if not is_by_door:
		return
	family_talking = false
	meow_counter += 1
	if not $SilentTimer2.is_stopped():
		start_dialogue("Story_1_3")
		await(DialogueManager.dialogue_ended)
		end_level()
	if not $SilentTimer1.is_stopped():
		$SilentTimer1.stop()
		$SilentTimer2.start()
	else:
		$SilentTimer1.start()
	if meow_counter >= 3 and not story_flag_1_2:
		story_flag_1_2 = true
		start_dialogue("Story_1_2")
		await(DialogueManager.dialogue_ended)
		$Tiger.max_energy += 1
	

func _on_tiger_meowed():
	_check_meow_by_door()

func _on_silent_timer_1_timeout():
	family_talking = true

func _on_silent_timer_2_timeout():
	family_talking = true

