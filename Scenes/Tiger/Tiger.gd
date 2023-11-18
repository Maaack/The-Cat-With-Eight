extends CharacterBody2D
class_name PlayerCharacter

signal meowed
signal jumped
signal jump_tried
signal meow_tried
signal sprint_tried

@export var acceleration : float = 600
@export var max_speed : float = 7500
@export var friction : float = 600
@export var speed_mod : float = 1.0
@export var sprint_speed_mod : float = 2.5
@export var sprint_enabled : bool = true
@export var jump_velocity : float = 100
@export var jump_energy_cost : int = 3
@export var meow_energy_cost : int = 1
@export var max_energy : int = 1 :
	set(value):
		max_energy = value
		$EnergyMeter.max_energy = max_energy
@export var carrying_carcass : bool = false

@onready var collision_shape_2d = $CollisionShape2D
#@onready var animation_tree = %CharacterAnimationTree
#@onready var animation_state : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var facing_direction : Vector2
var is_jumping : bool = false
var jump_input_flag : bool = false
var is_interacting : bool = false
var action_input_flag : bool = false
var accessible_interactables : Array = []
var active_node
var is_dead : bool = false


func face_direction(direction_vector : Vector2):
	if direction_vector.x > 0:
		if carrying_carcass:
			$AnimationPlayer.play("WalkingWithCarcassR")
		else:
			$AnimationPlayer.play("WalkingR")
	elif direction_vector.x < 0:
		if carrying_carcass:
			$AnimationPlayer.play("WalkingWithCarcassL")
		else:
			$AnimationPlayer.play("WalkingL")

	pass

func start_jump():
	jump_input_flag = false
	velocity.y -= jump_velocity
	is_jumping = true
	emit_signal("jumped")
	await(get_tree().create_timer(0.5).timeout)
	is_jumping = false

func try_jumping():
	emit_signal("jump_tried")
	if not $EnergyMeter.lower_energy(jump_energy_cost):
		return
	start_jump()

func start_interaction():
	is_interacting = true
	emit_signal("meowed")
	await(get_tree().create_timer(1.5).timeout)
	is_interacting = false

func try_interaction():
	emit_signal("meow_tried")
	if carrying_carcass:
		return
	if not $EnergyMeter.lower_energy(meow_energy_cost):
		return
	start_interaction()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func move_state(delta):
	velocity.y += gravity * delta
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector = input_vector.normalized()
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_jumping:
		try_jumping()
	if Input.is_action_just_pressed("interact") and not is_interacting:
		try_interaction()
	if input_vector != Vector2.ZERO:
		face_direction(input_vector)
		var total_speed_mod = speed_mod
		if Input.is_action_pressed("sprint"):
			emit_signal("sprint_tried")
			if sprint_enabled:
				total_speed_mod *= sprint_speed_mod
		var desired_velocity = (input_vector * max_speed * delta * total_speed_mod) + Vector2(0, velocity.y)
		var desired_acceleration = acceleration * delta * total_speed_mod
		if is_jumping:
			desired_acceleration *= 0.2
		velocity = velocity.move_toward(desired_velocity, desired_acceleration)
#		animation_state.travel("Walk")
	elif is_on_floor():
		if carrying_carcass:
			$AnimationPlayer.play("IdleWithCarcass")
		else:
			$AnimationPlayer.play("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta * speed_mod)
#		animation_state.travel("Idle")
	move_and_slide()

func _physics_process(delta):
	move_state(delta)

func _ready():
	max_energy = max_energy
