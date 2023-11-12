extends CharacterBody2D
class_name PlayerCharacter

@export var acceleration : float = 600
@export var max_speed : float = 7500
@export var friction : float = 600
@export var speed_mod : float = 1.0
@export var jump_velocity : float = 100

@onready var collision_shape_2d = $CollisionShape2D
#@onready var animation_tree = %CharacterAnimationTree
#@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var facing_direction : Vector2
var is_jumping : bool = false
var jump_input_flag : bool = false
var is_acting : bool = false
var action_input_flag : bool = false
var accessible_interactables : Array = []
var active_node
var is_dead : bool = false

func face_direction(_in):
	pass

func start_jump():
	jump_input_flag = false
	velocity.y -= jump_velocity
	is_jumping = true
	await(get_tree().create_timer(0.5).timeout)
	is_jumping = false
	pass

func start_action():
	pass

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func move_state(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector = input_vector.normalized()
	if jump_input_flag and not is_jumping:
		start_jump()
	if action_input_flag and not is_acting:
		start_action()
	if is_jumping:
		pass
	elif is_acting:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	elif input_vector != Vector2.ZERO:
		face_direction(input_vector)
		var desired_velocity = input_vector * max_speed * delta * speed_mod
		var desired_acceleration = acceleration * delta * speed_mod
		velocity = velocity.move_toward(desired_velocity, desired_acceleration)
#		animation_state.travel("Walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * speed_mod)
#		animation_state.travel("Idle")
	move_and_slide()

func _physics_process(delta):
	move_state(delta)

func _input(event):
	if event.get_action_strength("jump"):
		jump_input_flag = true
