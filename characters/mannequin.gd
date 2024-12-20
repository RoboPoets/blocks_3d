extends CharacterBody3D


enum InputVectorSpace {
	GLOBAL, ## Global space
	LOCAL,  ## Relative to the character's transform
	CAMERA, ## Relative to the camera's transform
}


## The default walk speed in m/s.
@export var max_speed:float = 6.0

## The default jump force at the moment of lift-off in m/s.
@export var jump_force:float = 4.0

## The amount of drag applied to this character while moving through the air.
## Measured in percentage of movement lost per second. NOTE: Does not affect
## gravity.
@export var air_drag:float = 0.02

## The gravity magnitude acting upon this character, measured in m/s^2.
@export var gravity:float = 9.8

## The speed at which the character rotates toward a given facing direction.
## Measured in deg/s, so a value of 180 means that the character takes 1 second
## to rotate by 180 degrees.
@export var rotation_rate:float = 540.0

## The default frame of reference that the character's input vector will
## be evaluated in. The default value is CAMERA, which is well suited for
## third-person character controllers.
@export var default_input_space: InputVectorSpace = InputVectorSpace.CAMERA

## If true, will start listening for player input when the game starts.
@export var current:bool = true

## The current frame of reference for evaluating the input vector.
@onready var current_input_space: InputVectorSpace = default_input_space

## The accumulated input vector for this character.
var current_input_vector:Vector3 = Vector3.ZERO

## The accumulated force at which this character launches when jumping.
var current_jump_force:float = 0.0

## Collects all traces that need to be performed during physics processing.
var trace_queue:Array

## Cache the name of the previous foot step anim notify.
## This is needed as a workaroud around the fact that walking and
## running animations are blended and the foot step notifies of both
## animations fire when they're active.
var last_foot_down:StringName


func _ready():
	set_process_unhandled_input(current)
	if current:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# move character in the direction of the input vector
	var current_vel:Vector3 = velocity
	var current_grav:float = current_vel.y

	var view_transform: Transform3D = Transform3D.IDENTITY
	if current_input_space == InputVectorSpace.LOCAL:
		view_transform = global_transform
	elif current_input_space == InputVectorSpace.CAMERA:
		var cam = get_viewport().get_camera_3d()
		if cam:
			view_transform = cam.global_transform

	var vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	current_input_vector = Vector3(vec.x, 0.0, vec.y)

	if is_on_floor():
		view_transform.basis.z = (view_transform.basis.z * Vector3(1,0,1)).normalized()
		var fwd:Vector3 = view_transform.basis.z * current_input_vector.z * max_speed
		var rgt:Vector3 = view_transform.basis.x * current_input_vector.x * max_speed

		current_vel = fwd + rgt
		current_vel = current_vel.normalized() * max(2.5, current_vel.length())
	else:
		current_vel *= (1 - air_drag * delta)
	current_vel.y = current_grav - gravity * delta + current_jump_force
	set_velocity(current_vel)
	move_and_slide()

	# Rotate character towards movement direction
	if current_input_vector != Vector3.ZERO && velocity != Vector3.ZERO:
		var up:Vector3 = global_transform.basis.y
		var forward:Vector3 = -global_transform.basis.z
		var dir:Vector3 = Plane(up, 0.0).project(velocity).normalized()

		var angle:float = forward.signed_angle_to(dir, up)
		var limit:float = delta * deg_to_rad(rotation_rate)
		rotate(up, clamp(angle, -limit, limit))

	# Pass data to animation state machine
	$AnimationTree.speed = velocity.length()
	$AnimationTree.in_air = not is_on_floor()

	# Process the trace queue
	var space:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	while not trace_queue.is_empty():
		var trace:Dictionary = trace_queue.pop_back()
		if trace.id == &"step":
			var result:Dictionary = space.intersect_ray(trace.params)
			if not result.is_empty() and result.collider.has_signal("touched"):
				result.collider.emit_signal("touched", result.position)

	# Reset all temporary force accumulations
	current_jump_force = 0.0
	current_input_vector = Vector3.ZERO


## Handles all the player input coming from connected input devices.
func _unhandled_input(event):
	if is_on_floor() and event.is_action_pressed("jump"):
		current_jump_force = jump_force


func on_anim_foot_down(bone:StringName):
	if bone == last_foot_down:
		return

	var skel:Skeleton3D = $Skeleton/Skeleton3D
	var bone_idx:int = skel.find_bone(bone)
	if bone_idx < 0:
		return

	var pos:Vector3 = (skel.global_transform * (skel.get_bone_global_pose(bone_idx))).origin
	var params:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = pos
	params.to = pos + Vector3(0,-0.5,0)
	trace_queue.append({ "id": &"step", "params": params })
	last_foot_down = bone
