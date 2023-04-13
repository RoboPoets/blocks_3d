extends Node3D

## If true, camera pitch should be clamped by [member pitch_range].
@export var limit_pitch_range:bool = false

## The lower threshold for camera pitching.
@export var min_pitch:float = -75.0

## The upper threshold for camera pitching.
@export var max_pitch:float = 75.0

## If true, the camera will listen for player input and adjust its rotation
## accordingly. TODO: for now only mouse movement is supported.
@export var enable_input:bool = true

## The sensitivity for mouse move inputs. TODO: this should be saved
## in a settings object and loaded from there.
@export_range(0.1, 1.0) var mouse_sensitivity:float = 0.25

## The sensitivity for joypad move inputs. TODO: this should be saved
## in a settings object and loaded from there.
@export_range(0.1, 1.0) var joypad_sensitivity:float = 0.25

## Invert camera movement direction along the X-axis.
@export var invert_x_axis:bool = false

## Invert camera movement direction along the Y-axis.
@export var invert_y_axis:bool = false

## The camera's default target. Has to be a node in the same scene.
@export var target:NodePath

## If true, the ancestor [Viewport] is currently using this camera.
@export var current: bool = false:
	get: return $CameraBoom/Camera.current
	set(value): $CameraBoom/Camera.current = value

@onready var _boom:SpringArm3D = $CameraBoom

## The camera's current target.
var current_target:Node3D

func _ready():
	if !target.is_empty():
		current_target = get_node(target)
	if current_target == null:
		set_process(false)

	set_process_unhandled_input(enable_input)


func _process(_delta):
	set_position(current_target.global_transform.origin)

	var vec:Vector2 = Vector2.ZERO
	vec.x = Input.get_action_strength("cam_right") - Input.get_action_strength("cam_left")
	vec.y = Input.get_action_strength("cam_down") - Input.get_action_strength("cam_up")
	vec *= joypad_sensitivity * 10.0
	_update_rotation(vec)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_update_rotation(event.relative * mouse_sensitivity)


func _update_rotation(delta:Vector2):
	if invert_x_axis:
		delta.x *= -1.0
	if invert_y_axis:
		delta.y *= -1.0
	rotation.y -= deg_to_rad(delta.x)
	var current_pitch:float = _boom.rotation.x - deg_to_rad(delta.y)
	if limit_pitch_range:
		current_pitch = clamp(current_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	_boom.rotation.x = current_pitch


func reset_rotation():
	_boom.rotation.x = 0.0
	set_rotation(current_target.rotation)


func set_target(new_target:Node3D):
	current_target = new_target
	set_process(current_target != null)
