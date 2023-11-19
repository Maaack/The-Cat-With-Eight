extends BaseLevel

@export var swat_force_mod : float = 10.0
@export var mother_throw_force : Vector2 = Vector2.ZERO
@export var boy_throw_force : Vector2 = Vector2.ZERO
@export var boy_low_throw_force : Vector2 = Vector2.ZERO

var tiger_jumps : int = 0
var paws_smacked_ball_away : int = 0
var first_jump_hint : bool = false
var second_jump_hint : bool = false
var ball_captures : int = 0
var first_capture : bool = false
var second_capture : bool = false
var third_throw : bool = false
var third_capture : bool = false
var hit_mothers_face : bool = false
var hit_sons_face : bool = false
var tiger_jumps_stronger : bool = false
var humans_needed_reminding : bool = false
var throw_force_cache : Vector2


func _check_jump_hints():
	await(get_tree().create_timer(1.5, false).timeout)
	if paws_smacked_ball_away >= 3 and not first_jump_hint:
		first_jump_hint = true
		start_dialogue("Paws_Keep_Pushing_It")
	elif paws_smacked_ball_away >= 6 and not second_jump_hint:
		second_jump_hint = true
		start_dialogue("Should_Attack_From_Above")
	elif paws_smacked_ball_away >= 9 and paws_smacked_ball_away % 3 == 0:
		start_dialogue("Should_Jump_On_Ball")

func _check_ball_catches():
	await(get_tree().create_timer(0.5, false).timeout)
	if ball_captures >= 1 and not first_capture:
		first_capture = true
		start_dialogue("Story_2_2")
		await(DialogueManager.dialogue_ended)
		random_throws_ball()
	elif ball_captures >= 2 and not second_capture:
		second_capture = true
		start_dialogue("Story_2_3")
		await(DialogueManager.dialogue_ended)
		random_throws_ball()
	elif ball_captures >= 3 and not third_capture:
		third_capture = true
		$Tiger/EnergyMeter.max_energy = 1
		$Tiger/EnergyMeter.current_energy = 0
		start_dialogue("Story_2_5")
		await(DialogueManager.dialogue_ended)
		boy_low_throws_ball()

func _start_level_ending():
	start_dialogue("Story_2_6")
	await(DialogueManager.dialogue_ended)
	var game_ui = get_tree().current_scene
	game_ui.transition_close()
	await(game_ui.transition_finished)
	$Tiger.set_physics_process(false)
	$MainCamera2D.enabled = false
	$PlayingKittySprite2D/Camera2D.enabled = true
	game_ui.transition_open()
	await(game_ui.transition_finished)
	start_dialogue("Story_2_7")
	await(DialogueManager.dialogue_ended)
	game_ui.transition_close()
	await(game_ui.transition_finished)
	end_level()

func _on_smack_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		if third_capture:
			$Tiger.velocity += Vector2(0, -350)
			await(get_tree().create_timer(0.75, false).timeout)
			_start_level_ending()
			return
		paws_smacked_ball_away += 1
		var relative_to_tiger : Vector2 = body.position - $Tiger.position
		relative_to_tiger.y = 0
		relative_to_tiger = relative_to_tiger.normalized()
		body.apply_impulse(relative_to_tiger * swat_force_mod)
		$NoBallActionTimer.start()
		_check_jump_hints()

func _check_ball_throws():
	await(get_tree().create_timer(0.5, false).timeout)
	$MomCatchesArea2D.monitoring = true
	$BoyCatchesArea2D.monitoring = true
	if second_capture and not third_throw:
		third_throw = true
		start_dialogue("Story_2_4")

func _prepare_to_throw(ball : RigidBody2D, from_position, ball_throw_force, wait_time):
	$MomCatchesArea2D.monitoring = false
	$BoyCatchesArea2D.monitoring = false
	ball.hide()
	ball.freeze = false
	ball.update_position = from_position
	throw_force_cache = ball_throw_force
	await(get_tree().create_timer(0.2, false).timeout)
	ball.set_collision_layer_value(2, true)
	ball.sleeping = true
	$HoldingBallTimer.start(1.0 + wait_time)
	$BallReminderTimer.start()
	
func throw_ball():
	$Ball.show()
	$Ball.apply_impulse(throw_force_cache)
	$NoBallActionTimer.start()
	_check_ball_throws()

func mother_throws_ball():
	var throw_timer = 1 + max(0,randfn(2,1))
	if randf() > 0.9:
		throw_timer += randf_range(6, 10)
	var throw_force = mother_throw_force * (1 + randf())
	_prepare_to_throw($Ball, $MotherThrowMarker2D.position, throw_force, throw_timer)

func boy_throws_ball():
	var throw_timer = 1 + max(0,randfn(2,1))
	if randf() > 0.8:
		throw_timer += randf_range(6, 16)
	var throw_force = boy_throw_force * (1 + randf())
	_prepare_to_throw($Ball, $BoyThrowMarker2D.position, throw_force, throw_timer)

func random_throws_ball():
	if randf() < 0.5:
		mother_throws_ball()
	else:
		boy_throws_ball()

func boy_low_throws_ball():
	_prepare_to_throw($Ball, $BoyLowThrowMarker2D.position, boy_low_throw_force, 1)

func _on_mom_catches_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		call_deferred("mother_throws_ball")

func _on_boy_catches_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		call_deferred("boy_throws_ball")

func _on_capture_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		ball_captures += 1
		body.set_collision_layer_value(2, false)
		body.set_deferred("freeze", true)
		$NoBallActionTimer.start()
		_check_ball_catches()

func _on_no_ball_action_timer_timeout():
	start_dialogue("Should_Hunt_Ball")

func _on_mother_face_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		if not hit_mothers_face:
			hit_mothers_face = true
			start_dialogue("Human_No_Like_Kitty_In_Face")
		body.velocity += Vector2(300, 0)

func _on_sons_face_area_2d_body_entered(body):
		if body.is_in_group(Constants.TIGER_GROUP):
			if not hit_sons_face:
				hit_sons_face = true
				start_dialogue("Human_Like_Kitty_In_Face")
			body.velocity += Vector2(-300, 0)

func tiger_jumped():
	tiger_jumps += 1
	if tiger_jumps >= 3 and not tiger_jumps_stronger:
		tiger_jumps_stronger = true
		await(get_tree().create_timer(0.75, false).timeout)
		start_dialogue("Getting_Stronger_From_Jumping")
		await(DialogueManager.dialogue_ended)
		$Tiger.max_energy += 1
	
func tiger_meowed(tiger_position : Vector2):
	super.tiger_meowed(tiger_position)
	if $HoldingBallTimer.is_stopped():
		return
	var time_left = $HoldingBallTimer.time_left * 0.2
	$HoldingBallTimer.start(time_left)

func _on_holding_ball_timer_timeout():
	$BallReminderTimer.stop()
	throw_ball()

func _on_ball_reminder_timer_timeout():
	if humans_needed_reminding:
		return
	humans_needed_reminding = true
	start_dialogue("Remind_Humans_About_Ball")

func _on_jump_instruction_timer_timeout():
	if tiger_jumps < 1:
		$JumpInstructions.show()

func _on_jump_instruction_timer_2_timeout():
	if tiger_jumps < 2:
		$JumpInstructions.show()
