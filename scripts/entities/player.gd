extends CharacterBody3D

@export var speed : float = 5.0 : set = set_speed
@export var jumpVel : float = 4.5 : set = set_jump
@export var sensitivity : float = 0.5 : set = set_sens

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var headPivot : Node3D = null : set = set_head
@export var cam : Camera3D = null : set = set_camera

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = jumpVel

	# Get input direction and handle movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (headPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Finish up
	move_and_slide()


func _unhandled_input(event):
	# Hide mouse
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Rotate head with mouse (bone cracking noises)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			headPivot.rotate_y(-event.relative.x * sensitivity * 0.01)
			cam.rotate_x(-event.relative.y * sensitivity * 0.01)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Setters/Getters
func set_speed(newSpeed):
	speed = newSpeed
func set_jump(newJump):
	jumpVel = newJump
# sens undertale??
func set_sens(newSens):
	sensitivity = newSens
func set_head(newHead):
	headPivot = newHead
func set_camera(newCam):
	cam = newCam
