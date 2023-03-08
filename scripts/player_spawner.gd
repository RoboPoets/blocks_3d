extends Node


const Types = preload("res://addons/blocks_3d/scripts/types.gd")


func _ready():
	if not OS.has_feature("editor"):
		queue_free()
		return

	var root:Window = get_tree().get_root()

	# Spawn default player character and camera
	if not get_tree().has_group("Player"): # TODO turn group name into setting
		print("No player character found, trying to spawn default character...")

		var cam:Node3D = create_default_camera()
		var player:CharacterBody3D = create_default_character()
		var pos:Vector3 = get_starting_position()

		if player:
			player.set_position(pos)
			root.call_deferred("add_child", player)

		if cam:
			if player:
				if cam.has_method("set_target"):
					cam.set_target(player)
			else:
				cam.set_position(pos)
			root.call_deferred("add_child", cam)

	# Spawn default directional light
	var suns = root.find_children("", "DirectionalLight3D", true, false)
	if len(suns) == 0:
		print("No directional light found, trying to spawn default sunlight...")
		var sun:Node3D = create_default_directional_light()
		if sun:
			root.call_deferred("add_child", sun)


func _unhandled_input(event):
	if event.is_action_released("ui_cancel"):
		get_tree().quit()


func get_starting_position() -> Vector3:
	var path = ProjectSettings.globalize_path("res://") + ".godot/editor"
	var file_name:String
	if DirAccess.dir_exists_absolute(path):
		var files:PackedStringArray = DirAccess.get_files_at(path)
		for f in files:
			if f.contains("city.tscn-editstate-"):
				file_name = f
				break
		prints(len(files), file_name)

	var viewports:Array
	if file_name:
		var cfg = ConfigFile.new()
		var err = cfg.load(path.path_join(file_name))
		if err == OK and cfg.has_section_key("editor_states", "3D"):
			viewports = cfg.get_value("editor_states", "3D").get("viewports", Array())

	if len(viewports) > 0:
		return viewports[0].get("position", Vector3.ZERO)

	return Vector3.ZERO


func create_default_camera() -> Node3D:
	var camera_file:String = ProjectSettings.get_setting(Types.settings_key_camera, "")
	if camera_file:
		var cam_scene:PackedScene = load(camera_file)
		if cam_scene:
			prints("Created default camera", camera_file)
			return cam_scene.instantiate()
	return null


func create_default_character() -> CharacterBody3D:
	var player_file:String = ProjectSettings.get_setting(Types.settings_key_character, "")
	if player_file:
		var player_scene:PackedScene = load(player_file)
		if player_scene:
			prints("Created default character", player_file)
			return player_scene.instantiate()
	return null


func create_default_directional_light() -> Node3D:
	var sun_file:String = ProjectSettings.get_setting(Types.settings_key_sun, "")
	if sun_file:
		var sun_scene:PackedScene = load(sun_file)
		if sun_scene:
			prints("Created default directional light", sun_file)
			return sun_scene.instantiate()
	return null
