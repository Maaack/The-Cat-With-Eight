extends AnimatedSprite2D


func _on_area_2d_body_entered(body):
	if body.is_in_group(Constants.MOUSE_GROUP):
		body.hide_in_bush()
