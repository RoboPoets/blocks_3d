extends Object

## The project settings key for the default character scene file. The scene
## should inherit from [CharacterBody3D].
const settings_key_character:String = "plugins/blocks_3d/default_character"

## The projects settings key for the default camera scene file. The scene
## should inherit from [Node3D]. If the camera is an independent scene and
## needs to follow the player around, it can can provide a "set_target" method
## to execute the setup code.
const settings_key_camera:String = "plugins/blocks_3d/default_camera"

## The projects settings key for the default directional light scene file.
## The scene should inherit from [Node3D].
const settings_key_sun:String = "plugins/blocks_3d/default_sun"

## The projects settings key for the node group that the game's default player
## character is a member of. This is used by the player spawner to determine
## whether a player character is already present in the scene.
const settings_key_node_group:String = "plugins/blocks_3d/default_character_node_group"


class PluginSettings:
	static func register_settings():
		add_custom_project_setting(settings_key_character, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
		add_custom_project_setting(settings_key_camera, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
		add_custom_project_setting(settings_key_sun, TYPE_STRING, "", PROPERTY_HINT_FILE, "*.tscn,*.scn")
		add_custom_project_setting(settings_key_node_group, TYPE_STRING, "Player")


	static func unregister_settings():
		ProjectSettings.set_setting(settings_key_character, null)
		ProjectSettings.set_setting(settings_key_camera, null)
		ProjectSettings.set_setting(settings_key_sun, null)
		ProjectSettings.set_setting(settings_key_node_group, null)


	static func add_custom_project_setting(name: String, type:int, default, hint:int = PROPERTY_HINT_NONE, hint_string:String = ""):
		if not ProjectSettings.has_setting(name):
			ProjectSettings.set_setting(name, default)
			ProjectSettings.set_initial_value(name, default)

		var info:Dictionary = {
			"name": name,
			"type": type,
			"hint": hint,
			"hint_string": hint_string,
		}

		ProjectSettings.add_property_info(info)
