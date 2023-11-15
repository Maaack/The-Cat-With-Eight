extends BaseLevel

@export var swat_force_mod : float = 10.0
@export var mother_throw_force : Vector2 = Vector2.ZERO
@export var boy_throw_force : Vector2 = Vector2.ZERO
@export var boy_low_throw_force : Vector2 = Vector2.ZERO

var paws_smacked_ball_away : int = 0
var first_jump_hint : bool = false
var second_jump_hint : bool = false
var ball_captures : int = 0
var first_capture : bool = false
var second_capture : bool = false
var third_throw : bool = false
var third_capture : bool = false


func _ready():
	super._ready()

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
	await(get_tree().create_timer(1.5, false).timeout)
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
		_check_jump_hints()

func _check_ball_throws():
	await(get_tree().create_timer(0.5, false).timeout)
	$MomCatchesArea2D.monitoring = true
	$BoyCatchesArea2D.monitoring = true
	if second_capture and not third_throw:
		third_throw = true
		start_dialogue("Story_2_4")

func throw_ball(ball : RigidBody2D, from_position, throw_force):
	$MomCatchesArea2D.monitoring = false
	$BoyCatchesArea2D.monitoring = false
	var wait_time = max(0,randfn(2,1))
	ball.hide()
	ball.freeze = false
	ball.update_position = from_position
	await(get_tree().create_timer(0.2, false).timeout)
	ball.set_collision_layer_value(2, true)
	ball.sleeping = true
	await(get_tree().create_timer(1.0 + wait_time, false).timeout)
	ball.show()
	ball.apply_impulse(throw_force)
	_check_ball_throws()

func mother_throws_ball():
	throw_ball($Ball, $MotherThrowMarker2D.position, mother_throw_force * (1 + randf()))

func boy_throws_ball():
	throw_ball($Ball, $BoyThrowMarker2D.position, boy_throw_force * (1 + randf()))

func random_throws_ball():
	if randf() < 0.5:
		mother_throws_ball()
	else:
		boy_throws_ball()

func boy_low_throws_ball():
	throw_ball($Ball, $BoyLowThrowMarker2D.position, boy_low_throw_force)

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
		_check_ball_catches()
