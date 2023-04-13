@tool
extends EditorPlugin
## This plugin provides assets and scripts to help getting started with
## blocking out 3D levels and improve iteration times.


const Types = preload("res://addons/blocks_3d/scripts/types.gd")


func _enable_plugin():
	add_autoload_singleton("PlayerSpawner", "res://addons/blocks_3d/scripts/player_spawner.gd")


func _disable_plugin():
	remove_autoload_singleton("PlayerSpawner")


func _enter_tree():
	Types.PluginSettings.register_settings()


func _exit_tree():
	Types.PluginSettings.unregister_settings()

