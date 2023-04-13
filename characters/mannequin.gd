extends CharacterBody3D


## The default walk speed in m/s.
@export var max_speed:float = 6.0

## The gravity magnitude acting upon this character, measured in m/s^2.
@export var gravity:float = 9.8

## The speed at which the character rotates toward a given facing direction.
## Measured in deg/s, so a value of 180 means that the character takes 1 second
## to rotate by 180 degrees.
@export var rotation_rate:float = 540.0

## If true, will start listening for player input when the game starts.
@export var current:bool = true

## The accumulated input vector for this character.
var current_input_vector:Vector3 = Vector3.ZERO


func _ready():
	set_process_unhandled_input(current)


## Handles character movement and rotation.
func _physics_process(delta):
	var current_vel:Vector3 = velocity
	var current_grav:float = current_vel.y
	var view_transform: Transform3D = global_transform
	var camera = get_viewport().get_camera_3d()
	if camera:
		view_transform = camera.global_transform

	view_transform.basis.z = (view_transform.basis.z * Vector3(1,0,1)).normalized()
	var fwd:Vector3 = view_transform.basis.z * current_input_vector.z * max_speed
	var rgt:Vector3 = view_transform.basis.x * current_input_vector.x * max_speed

	current_vel = fwd + rgt
	current_vel = current_vel.normalized() * max(2.5, current_vel.length())
	current_vel.y = current_grav - gravity * delta
	set_velocity(current_vel)
	move_and_slide()

	if current_input_vector != Vector3.ZERO && velocity != Vector3.ZERO:
		var up:Vector3 = global_transform.basis.y
		var forward:Vector3 = -global_transform.basis.z
		var dir:Vector3 = Plane(up, 0.0).project(velocity).normalized()

		var angle:float = forward.signed_angle_to(dir, up)
		var limit:float = delta * deg_to_rad(rotation_rate)
		rotate(up, clamp(angle, -limit, limit))

	$AnimationTree.speed = velocity.length()


## Handles all the player input coming from connected input devices.
func _unhandled_input(event):
	var vec:Vector3 = Vector3.ZERO
	vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	vec.z = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	current_input_vector = vec.normalized() if vec.length() > 1 else vec

