extends Node2D

@export var energy_sprite_frames : SpriteFrames

@export var max_energy : int = 0 :
	set(value):
		if value == 0:
			_clear_children()
			max_energy = 0
		else:
			while value > max_energy:
				max_energy += 1
				raise_max_energy()
			while value < max_energy:
				max_energy -= 1
				lower_max_energy()
		
@export var energy_recharge_time : float = 3.0 :
	set(value):
		energy_recharge_time = value
		$RechargeTimer.wait_time = energy_recharge_time
@export var sprite_size : float = 16.0 :
	set(value):
		sprite_size = value
		_reposition_elements()

@export var sprite_spacing : float = 4.0 :
	set(value):
		sprite_spacing = value
		_reposition_elements()

@export var energy_modulate : Color = Color.WHITE

var current_energy = 0 :
	set(value):
		current_energy = value
		_modulate_elements()
var light_up_new_energy = false

func _check_energy_recharge():
	if current_energy >= max_energy:
		current_energy = max_energy
		return
	if not $RechargeTimer.is_inside_tree():
		return
	if $RechargeTimer.is_stopped():
		$RechargeTimer.start()

func _clear_children():
	var children := $Container.get_children()
	for child in children:
		child.queue_free()

func _rebuild_sprites():
	_clear_children()
	for i in max_energy:
		var instance = AnimatedSprite2D.new()
		instance.sprite_frames = energy_sprite_frames
		instance.autoplay = "default"
		$Container.add_child(instance)

func _reposition_elements():
	if not is_inside_tree():
		return
	var child_count : int = $Container.get_child_count()
	if child_count == 0:
		return
	var total_space : float = (child_count - 1) * (sprite_size + sprite_spacing)
	var starting_position = -(total_space/2.0)
	var iter = 0
	for child in $Container.get_children():
		child.position.x = starting_position + (iter * (sprite_spacing + sprite_size))
		iter += 1

func raise_max_energy():
	if not is_inside_tree():
		return
	var instance = AnimatedSprite2D.new()
	instance.sprite_frames = energy_sprite_frames
	instance.autoplay = "default"
	$Container.add_child(instance)
	_reposition_elements()
	_modulate_elements()
	_check_energy_recharge()
	if light_up_new_energy:
		$GPUParticles2D.position = instance.position
		$GPUParticles2D.emitting = true

func lower_max_energy():
	if not is_inside_tree():
		return
	var child_count : int = $Container.get_child_count()
	if child_count == 0:
		return
	for i in range(max_energy, child_count):
		var child = $Container.get_child(i)
		child.queue_free()
	if not is_inside_tree():
		return
	await(get_tree().create_timer(0.1).timeout)
	_reposition_elements()

func _modulate_elements():
	var iter : int = 0
	for child in $Container.get_children():
		if not child is AnimatedSprite2D:
			continue
		if iter >= current_energy:
			child.modulate = energy_modulate
		else:
			child.modulate = Color.WHITE
		iter += 1

func raise_energy(amount : int = 1):
	current_energy += amount
	if current_energy > max_energy:
		current_energy == max_energy
	_modulate_elements()
	_check_energy_recharge()

func lower_energy(amount : int = 1) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	_modulate_elements()
	$RechargeTimer.start()
	return true

func _on_recharge_timer_timeout():
	raise_energy()

func _ready():
	_rebuild_sprites()
	_reposition_elements()
	await(get_tree().create_timer(0.05).timeout)
	current_energy = max_energy
	light_up_new_energy = true
