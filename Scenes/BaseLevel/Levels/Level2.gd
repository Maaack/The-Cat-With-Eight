extends BaseLevel

@export var swat_force_mod : float = 10.0
@export var mother_throw_force : Vector2 = Vector2.ZERO
@export var boy_throw_force : Vector2 = Vector2.ZERO

func _ready():
	super._ready()

func _on_smack_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		var relative_to_tiger : Vector2 = body.position - $Tiger.position
		relative_to_tiger.y = 0
		relative_to_tiger = relative_to_tiger.normalized()
		body.apply_impulse(relative_to_tiger * swat_force_mod)

func throw_ball(ball : RigidBody2D, from_position, throw_force):
	var wait_time = max(0,randfn(2,1))
	ball.hide()
	ball.update_position = from_position
	await(get_tree().create_timer(0.05, false).timeout)
	ball.sleeping = true
	await(get_tree().create_timer(1.0 + wait_time, false).timeout)
	ball.show()
	ball.apply_impulse(throw_force * (1 + randf()))

func mother_throws_ball(ball : RigidBody2D):
	throw_ball(ball, $MotherThrowMarker2D.position, mother_throw_force)

func boy_throws_ball(ball : RigidBody2D):
	throw_ball(ball, $BoyThrowMarker2D.position, boy_throw_force)

func _on_mom_catches_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		call_deferred("mother_throws_ball", body)

func _on_boy_catches_area_2d_body_entered(body):
	if body.is_in_group(Constants.BALL_GROUP):
		call_deferred("boy_throws_ball", body)
