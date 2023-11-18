extends CharacterBody2D

signal left_hiding_spot
signal played_dead

@export var acceleration : float = 1800
@export var max_speed : float = 9000
@export var friction : float = 1800
@export var sprint_speed_mod : float = 2.5
@export var catapult_vector : Vector2 = Vector2.ZERO
var fleeing : bool = false
var current_threat
var in_bush : bool = false
var action_vector : Vector2 = Vector2.ZERO
var playing_dead : bool = false
var airborne : bool = false
var hiding_bush

func _on_awareness_area_2d_body_entered(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		$AlertTimer.stop()
		fleeing = true
		current_threat = body

func _on_awareness_area_2d_body_exited(body):
	if body.is_in_group(Constants.TIGER_GROUP):
		$AlertTimer.start()

func _on_alert_timer_timeout():
	fleeing = false
	current_threat = null
	leave_bush()
	action_vector.x = 1.0 if randf() > 0.5 else -1.0

func face_direction(direction_vector : Vector2):
	if direction_vector.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction_vector.x < 0:
		$AnimatedSprite2D.flip_h = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func move_state(delta):
	velocity.y += gravity * delta
	if fleeing:
		var direction_away : Vector2 = position - current_threat.position
		direction_away.y = 0
		action_vector = direction_away.normalized() * sprint_speed_mod
	if playing_dead:
		action_vector = Vector2.ZERO
	if is_on_floor():
		if airborne:
			airborne = false
			if playing_dead:
				$AnimationPlayer.play("Dead")
			else:
				$AnimationPlayer.play("RESET")
				set_collision_layer_value(2, true)
		if action_vector != Vector2.ZERO:
			face_direction(action_vector)
			var desired_velocity = (action_vector * max_speed * delta) + Vector2(0, velocity.y)
			var desired_acceleration = acceleration * delta
			velocity = velocity.move_toward(desired_velocity, desired_acceleration)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		airborne = true
	move_and_slide()

func catapult():
	velocity = catapult_vector
	if randf() > 0.5:
		velocity.x = -velocity.x
	$AnimationPlayer.play("Rolling")

func _physics_process(delta):
	move_state(delta)

func hide_in_bush(bush : Node2D) -> bool:
	if playing_dead or in_bush or not fleeing:
		return false
	hiding_bush = bush
	in_bush = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_collision_layer_value(2, false)
	hide()
	return true

func leave_bush():
	if not in_bush:
		return
	in_bush = false
	hiding_bush.stop_squeaks()
	hiding_bush = null
	set_physics_process(true)
	set_collision_layer_value(2, true)
	show()
	emit_signal("left_hiding_spot")

func play_dead():
	playing_dead = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Dead":
		emit_signal("played_dead")
		set_collision_layer_value(2, true)
