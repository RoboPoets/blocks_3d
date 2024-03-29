# Blocks (3D)

This plugin provides assets and scripts to help getting started with
blocking out 3D levels and improve iteration times. It contains modular
scenes for architecture, furniture, and decorative elements. It also contains
an autoload script that takes care of spawning a default character, camera,
and directional light if it doesn't find any of these in the running scene.

## Blockout Assets

The assets in this plugin can be found in the `props` folder and are separated
thematically. There are lots of modular pieces to quickly set up building
interiors and exteriors. There are different types of furniture and some
decorative props.

Most of the assets are composed of CSGs. This has the advantage that the
overall size of the addon can be kept small. The downside is that CSG is
heavier on performance than regular meshes, so very large scenes filled
with lots of them might make the framerate suffer.

## Third-Person Character

The plugin comes with a ready-to-play third-person character controller and
camera. The character is animated and can blend seamlessly between idle, walk,
and run animations. There are several skins and color schemes available
to quickly customize team colors and NPCs.

Both character and camera support gamepads as well as keyboard/mouse controls.
The camera controls can be inverted on both axes and sensitivity can be adjusted
for mouse and analog stick separately. You need to create the following input
actions in your project:

- **walk_forward**: Character forward movement
- **walk_back**: Character backwards movement
- **walk_left**: Character movement to the left
- **walk_right**: Character movement to the right
- **cam_up**: Camera tilt, up if not inverted
- **cam_down**: Camera tilt, down if not inverted
- **cam_left**: Camera pan, to the left if not inverted
- **cam_right**: Camera pan, to the right if not inverted

> **_Note:_** The character always faces in the direction of movement, strafing
> is currently not supported.

## Playtesting

In order to iterate quickly on levels, especially on streaming levels
that might not contain a complete environment on their own, the addon
provides the `PlayerSpawner` class that is automatically added as an
autoload when the plugin is activated.

`PlayerSpawner` tries to find a player character and a camera in the
scene when playtesting starts. It does so by querying the NodeGroup
system. if it doesn't find any, it tries to spawn them. The scenes it
spawns can be set in the project settings under the **Plugin/Blocks 3D**
category. It also reads the current position of the editor camera to
set the player character's spawn location. This is helpful in large
scenes where you might want to spawn at very different locations during
your testing sessions.

The spawner also looks for a directional light in the scene. If it
doesn't find any, it spawns one, again looking in the project settings
to determine which scene file to instatiate.

## Roadmap

- [ ] 2D version of this plugin, tailored specifically to 2D games
- [X] Basic animated character controller
- [X] Player-controlled third-person camera
- [ ] Tools, weapons, and items
- [ ] Rocks, rivers, and plants
