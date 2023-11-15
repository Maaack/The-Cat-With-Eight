extends RigidBody2D

@export var update_position : Vector2 = Vector2.ZERO
@export var update_velocity : Vector2 = Vector2.ZERO
	
func _integrate_forces(state):
	if not update_position.is_zero_approx():
		state.transform = Transform2D(0.0, update_position)
		update_position = Vector2.ZERO
	if not update_velocity.is_zero_approx():
		state.linear_velocity = update_velocity
		update_velocity = Vector2.ZERO
