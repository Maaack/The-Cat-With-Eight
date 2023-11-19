extends AnimatedSprite2D

signal mouse_squeaked(position)

func _on_area_2d_body_entered(body):
	if body.is_in_group(Constants.MOUSE_GROUP):
		if body.hide_in_bush(self):
			disable_spot()
			start_squeaks()

func start_squeaks():
	$SqueakTimer.start()

func stop_squeaks():
	$SqueakTimer.stop()

func enable_spot():
	$Area2D.set_deferred("monitoring", true)

func disable_spot():
	$Area2D.set_deferred("monitoring", false)

func _on_timer_timeout():
	$SqueakStreamPlayer2D.play()
	emit_signal("mouse_squeaked", self.position)
