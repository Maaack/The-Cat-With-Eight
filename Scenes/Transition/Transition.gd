extends ColorRect

signal transition_finished

@export var closed_size : float = 0
@export var opened_sized : float = 1.1
@export var tween_time : float = 1

func close():
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/circle_size", closed_size, tween_time)
	await(tween.finished)
	emit_signal("transition_finished")

func open():
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/circle_size", opened_sized, tween_time)
	await(tween.finished)
	emit_signal("transition_finished")

func instant_close():
	material.set("shader_parameter/circle_size", closed_size)

func instant_open():
	material.set("shader_parameter/circle_size", opened_sized)

