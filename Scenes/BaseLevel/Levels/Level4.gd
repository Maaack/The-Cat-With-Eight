extends BaseLevel

@export_file var end_credits_path : String

func _on_end_level_timer_timeout():
	var game_ui = get_tree().current_scene
	game_ui.transition_close()
	await(game_ui.transition_finished)
	SceneLoader.load_scene(end_credits_path)
