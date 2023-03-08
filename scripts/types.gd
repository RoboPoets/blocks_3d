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
