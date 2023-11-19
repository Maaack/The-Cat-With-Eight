extends Node

@export_file("*.tscn") var opening_scene : String
@export_file("*.tscn") var main_menu_scene : String

func _ready():
	AppLog.app_opened()
	AppSettings.set_from_config_and_window(get_window())
	if GameLog.has_seen_opening():
		SceneLoader.load_scene(main_menu_scene)
	else:
		SceneLoader.load_scene(opening_scene)
