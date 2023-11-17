extends CharacterBody2D

signal left_hiding_spot

@export var acceleration : float = 1800
@export var max_speed : float = 9000
@export var friction : float = 1800
var fleeing : bool = false
var current_threat
var in_bush : bool = false
var action_vector : Vector2 = Vector2.ZERO

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
		action_vector = direction_away.normalized()
	else:
		pass
	if action_vector != Vector2.ZERO:
		face_direction(action_vector)
		var desired_velocity = (action_vector * max_speed * delta) + Vector2(0, velocity.y)
		var desired_acceleration = acceleration * delta
		velocity = velocity.move_toward(desired_velocity, desired_acceleration)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

func _physics_process(delta):
	move_state(delta)

func hide_in_bush() -> bool:
	if in_bush or not fleeing:
		return false
	in_bush = true
	set_physics_process(false)
	set_collision_layer_value(2, false)
	hide()
	return true

func leave_bush():
	if not in_bush:
		return
	in_bush = false
	set_physics_process(true)
	set_collision_layer_value(2, true)
	show()
	emit_signal("left_hiding_spot")
