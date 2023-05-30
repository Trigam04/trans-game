extends CharacterBody3D

# Enums
enum States { WALKING, SPRINTING, CROUCHING, AIR, AIR_SPRINTING }
var state = States.WALKING

# Movement
@export_group("Movement Properties")
@export var speed : float = 5.0 : set = set_speed
@export var sprintSpeed : float = 8.5 : set = set_sprint_speed
@export var jumpVel : float = 4.5 : set = set_jump
# Cam
@export_group("Camera Properties")
@export var sensitivity : float = 0.5 : set = set_sens
@export var fov : float = 70 : set = set_fov
@export var sprintFOV : float = 100 : set = set_sprint_fov
# Nodes
@export_group("Nodes")
@export var headPivot : Node3D = null : set = set_head
@export var cam : Camera3D = null : set = set_camera
@export var debugMenu : Control = null : set = set_debug

# Internal Vars
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var currentSpeed = speed

func _physics_process(delta):
	# Start calculations
	calculateState()
	
	# Add gravity
	if state == States.AIR or state == States.AIR_SPRINTING:
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = jumpVel
	
	# Calculate speed
	if state == States.SPRINTING or state == States.AIR_SPRINTING:
		currentSpeed = sprintSpeed
		Util.tweenVal(cam, "fov", sprintFOV, 0.25)
	else:
		currentSpeed = speed
		Util.tweenVal(cam, "fov", fov, 0.25)

	# Get input direction and handle movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (headPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	# Finish up
	move_and_slide()
	
	# Debug
	if (debugMenu):
		debugMenu.set_player_coords(self.get_position())
		debugMenu.set_player_state(Util.get_enum_val_as_string(States, state))
		debugMenu.set_player_speed(Util.round_to_dec(self.velocity.length(), 2))

func _unhandled_input(event):
	# Hide mouse
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Change sensitivity with Scroll Wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			sensitivity += 0.01
			if sensitivity > 1:
				sensitivity = 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			sensitivity -= 0.01
			if sensitivity < 0:
				sensitivity = 0
	
	# Rotate head with mouse (bone cracking noises)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			headPivot.rotate_y(-event.relative.x * sensitivity * 0.01)
			cam.rotate_x(-event.relative.y * sensitivity * 0.01)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func calculateState():
	if not is_on_floor() and Input.is_action_pressed("move_sprint"):
		state = States.AIR_SPRINTING
	elif not is_on_floor():
		state = States.AIR
	elif Input.is_action_pressed("move_sprint"):
		state = States.SPRINTING
	else:
		state = States.WALKING

# Setters/Getters
func set_speed(newSpeed):
	speed = newSpeed
func set_sprint_speed(newSpeed):
	sprintSpeed = newSpeed
func set_jump(newJump):
	jumpVel = newJump
# sens undertale??
func set_sens(newSens):
	sensitivity = newSens
func set_head(newHead):
	headPivot = newHead
func set_camera(newCam):
	cam = newCam
func set_fov(newFOV):
	fov = newFOV
func set_sprint_fov(newSprintFOV):
	sprintFOV = newSprintFOV
func set_debug(newDebug):
	debugMenu = newDebug
