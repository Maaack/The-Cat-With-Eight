extends BaseLevel

var meow_counter : int = 0

func _on_move_instruction_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		$MoveInstructionsTimer.start()

func _on_move_instructions_timer_timeout():
	$MoveInstructionsSprite2D.show()


func _on_meow_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		$MeowTimer.start()

func _on_meow_timer_timeout():
	$MeowSprite2D.show()


func _on_tiger_meowed():
	meow_counter += 1
	if meow_counter >= 3:
		end_level()
