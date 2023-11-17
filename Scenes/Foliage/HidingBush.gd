extends AnimatedSprite2D


func _on_area_2d_body_entered(body):
	if body.is_in_group(Constants.MOUSE_GROUP):
		if body.hide_in_bush():
			disable_spot()

func enable_spot():
	$Area2D.set_deferred("monitoring", true)

func disable_spot():
	$Area2D.set_deferred("monitoring", false)
