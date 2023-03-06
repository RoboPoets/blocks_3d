@tool
extends EditorPlugin


const Types = preload("res://addons/blocks_3d/scripts/types.gd")


func _enter_tree():
	add_custom_project_setting(Types.settings_key_character, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
	add_custom_project_setting(Types.settings_key_camera, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
	add_custom_project_setting(Types.settings_key_sun, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
	add_custom_project_setting(Types.settings_key_env, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tres,*.res")
	add_autoload_singleton("PlayerSpawner", "res://addons/blocks_3d/scripts/player_spawner.gd")


func _exit_tree():
	ProjectSettings.set_setting(Types.settings_key_character, null)
	ProjectSettings.set_setting(Types.settings_key_camera, null)
	ProjectSettings.set_setting(Types.settings_key_sun, null)
	ProjectSettings.set_setting(Types.settings_key_env, null)
	remove_autoload_singleton("PlayerSpawner")


func add_custom_project_setting(name: String, type:int, default, hint:int = PROPERTY_HINT_NONE, hint_string:String = ""):
	if not ProjectSettings.has_setting(name):
		var info:Dictionary = {
			"name": name,
			"type": type,
			"hint": hint,
			"hint_string": hint_string,
		}

		ProjectSettings.set_setting(name, default)
		ProjectSettings.add_property_info(info)
		ProjectSettings.set_initial_value(name, default)
