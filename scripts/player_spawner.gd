extends Node
## PlayerSpawner spawns nodes for playtesting when a level is run from the
## editor.
##
## When it detects that the level does not contain a camera, a player character,
## or a directional light, it tries to spawn them by creating the respective
## scenes defined in the project settings (see Project Settings -> Plugins ->
## Blocks 3D). Additionally, the player character and camera are spawned at
## the level's current editor camera position. This makes it very convenient
## for testing larger maps.
##
## [b]Waring:[/b] This class is not supposed to be used in exported games. It
## will not work in exported games and should not be relied upon. It can be
## exported safely along with the other game files, but it will destroy itself
## immediately if it detects that it is running in an exported build.


const Types = preload("res://addons/blocks_3d/scripts/types.gd")


func _enter_tree():
	Types.PluginSettings.register_settings()


func _ready():
	## Abort if in exported game
	if not OS.has_feature("editor"):
		queue_free()
		return

	var root:Window = get_tree().get_root()
	var player:CharacterBody3D = null
	var cam:Node3D = null

	# Spawn default player character
	var player_group:String = ProjectSettings.get_setting(Types.settings_key_char_node_group, "")
	if not player_group.is_empty() and not get_tree().has_group(player_group):
		print("No player character found, trying to spawn default character...")

		player = create_default_character()
		if player:
			player.add_to_group(player_group)
			player.set_position(get_starting_position())
			root.call_deferred("add_child", player)
	else:
		for n in get_tree().get_nodes_in_group(player_group):
			if n is CharacterBody3D:
				player = n
				break

	# Spawn default player camera
	var cam_group:String = ProjectSettings.get_setting(Types.settings_key_cam_node_group, "")
	if not cam_group.is_empty() and not get_tree().has_group(cam_group):
		print("No player camera found, trying to spawn default camera...")

		cam = create_default_camera()
		if cam:
			if player != null and cam.has_method("set_target"):
				cam.set_target(player)
			else:
				cam.set_position(get_starting_position())
			cam.add_to_group(cam_group)
			root.call_deferred("add_child", cam)

	# Spawn default directional light
	var suns = root.find_children("", "DirectionalLight3D", true, false)
	if len(suns) == 0:
		print("No directional light found, trying to spawn default sunlight...")
		var sun:Node3D = create_default_directional_light()
		if sun:
			root.call_deferred("add_child", sun)


## Quit the game if the [code]ui_cancel[/code] key is pressed. This defaults
## to the [kbd]Escape[/kbd] key on most operating systems. This operation can
## interfere with your UI if you don't call [method Viewport.set_input_as_handled]
## in your input-handling classes.
func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		get_tree().quit()


## Return the editor camera's location in the current scene. This reads from
## the first viewport only and ignores the other three viewports, whether
## they are visible or not.
func get_starting_position() -> Vector3:
	var scene_file:String = get_tree().current_scene.scene_file_path.get_file()
	var data_path = ProjectSettings.globalize_path("res://") + ".godot/editor"
	var file_name:String
	if DirAccess.dir_exists_absolute(data_path):
		var files:PackedStringArray = DirAccess.get_files_at(data_path)
		for f in files:
			if f.begins_with(scene_file + "-editstate-"):
				file_name = f
				break

	var viewports:Array
	if file_name:
		var cfg = ConfigFile.new()
		var err = cfg.load(data_path.path_join(file_name))
		if err == OK and cfg.has_section_key("editor_states", "3D"):
			viewports = cfg.get_value("editor_states", "3D").get("viewports", Array())

	if len(viewports) > 0:
		return viewports[0].get("position", Vector3.ZERO)

	return Vector3.ZERO


## Create the playtest camera from the scene file set in the project settings.
func create_default_camera() -> Node3D:
	var camera_file:String = ProjectSettings.get_setting(Types.settings_key_camera, "")
	if camera_file:
		var cam_scene:PackedScene = load(camera_file)
		if cam_scene:
			prints("Created default camera", camera_file)
			return cam_scene.instantiate()
	return null


## Create the playtest character from the scene file set in the project settings.
func create_default_character() -> CharacterBody3D:
	var player_file:String = ProjectSettings.get_setting(Types.settings_key_character, "")
	if player_file:
		var player_scene:PackedScene = load(player_file)
		if player_scene:
			prints("Created default character", player_file)
			return player_scene.instantiate()
	return null


## Create the playtest sunlight from the scene file set in the project settings.
func create_default_directional_light() -> Node3D:
	var sun_file:String = ProjectSettings.get_setting(Types.settings_key_sun, "")
	if sun_file:
		var sun_scene:PackedScene = load(sun_file)
		if sun_scene:
			prints("Created default directional light", sun_file)
			return sun_scene.instantiate()
	return null
