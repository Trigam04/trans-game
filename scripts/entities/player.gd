extends CharacterBody3D

# Enums
enum MovementStates { WALKING, SPRINTING, CROUCHING, CRAWLING }
enum PositionStates { GROUND, AIR }
var moveState = MovementStates.WALKING
var posState = PositionStates.GROUND

# Movement
@export_group("Movement Properties")
@export var speed : float = 5.0 : set = set_speed
@export var sprintSpeed : float = 8.5 : set = set_sprint_speed
@export var crouchSpeed : float = 2.5 : set = set_crouch_speed
@export var crawlSpeed : float = 1 : set = set_crawl_speed
@export var jumpVel : float = 4.5 : set = set_jump
# Cam
@export_group("Camera Properties")
@export var sensitivity : float = 0.5 : set = set_sens
@export var fov : float = 70 : set = set_fov
@export var sprintFOV : float = 100 : set = set_sprint_fov
@export var crouchFOV : float = 60 : set = set_crouch_fov
@export var crawlFOV : float = 50 : set = set_crawl_fov
# Colliders
@export var standingCollider : CollisionShape3D = null : set = set_stand_col
@export var crouchingCollider : CollisionShape3D = null : set = set_crouch_col
@export var crawlingCollider : CollisionShape3D = null : set = set_crawl_col
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
	handleState()
	
	# Add gravity
	if posState == PositionStates.AIR:
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = jumpVel

	# Get input direction and handle movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (self.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	# Finish up
	move_and_slide()
	
	# Pass values to debug menu
	if (debugMenu): passDebug()

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
			self.rotate_y(-event.relative.x * sensitivity * 0.01)
			cam.rotate_x(-event.relative.y * sensitivity * 0.01)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func calculateState():
	# Pos State
	if not is_on_floor():
		posState = PositionStates.AIR
	else:
		posState = PositionStates.GROUND
	# Move State
	if Input.is_action_pressed("move_crawl"):
		moveState = MovementStates.CRAWLING
	elif Input.is_action_pressed("move_crouch"):
		moveState = MovementStates.CROUCHING
	elif Input.is_action_pressed("move_sprint"):
		moveState = MovementStates.SPRINTING
	else:
		moveState = MovementStates.WALKING

func handleState():
	# SPEED / FOV
	match moveState:
		MovementStates.SPRINTING:
			currentSpeed = sprintSpeed
			Util.tweenVal(cam, "fov", sprintFOV, 0.25)
			Util.tweenVal(headPivot, "position", Vector3(0, 0.65, 0), 0.25)
		MovementStates.CROUCHING:
			currentSpeed = crouchSpeed
			Util.tweenVal(cam, "fov", crouchFOV, 0.25)
			Util.tweenVal(headPivot, "position", Vector3(0, -0.25, 0), 0.25)
		MovementStates.CRAWLING:
			currentSpeed = crawlSpeed
			Util.tweenVal(cam, "fov", crawlFOV, 0.25)
			Util.tweenVal(headPivot, "position", Vector3(0, -0.8, 0), 0.25)
		MovementStates.WALKING:
			currentSpeed = speed
			Util.tweenVal(cam, "fov", fov, 0.25)
			Util.tweenVal(headPivot, "position", Vector3(0, 0.53, 0), 0.25)
	changeCollider(moveState)

func changeCollider(state):
	match state:
		MovementStates.CROUCHING:
			standingCollider.disabled = true
			crouchingCollider.disabled = false
			crawlingCollider.disabled = true
		MovementStates.CRAWLING:
			standingCollider.disabled = true
			crouchingCollider.disabled = true
			crawlingCollider.disabled = false
		_:
			standingCollider.disabled = false
			crouchingCollider.disabled = true
			crawlingCollider.disabled = true



func passDebug():
	debugMenu.set_player_coords(self.get_position())
	debugMenu.set_player_move_state(Util.get_enum_val_as_string(MovementStates, moveState))
	debugMenu.set_player_pos_state(Util.get_enum_val_as_string(PositionStates, posState))
	debugMenu.set_player_speed(Util.round_to_dec(self.velocity.length(), 2))
	debugMenu.set_cam_fov(Util.round_to_dec(cam.fov, 2))

# Setters/Getters
func set_speed(newSpeed):
	speed = newSpeed
func set_sprint_speed(newSpeed):
	sprintSpeed = newSpeed
func set_crouch_speed(newSpeed):
	crouchSpeed = newSpeed
func set_crawl_speed(newSpeed):
	crawlSpeed = newSpeed
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
func set_crouch_fov(newFOV):
	crouchFOV = newFOV
func set_crawl_fov(newFOV):
	crawlFOV = newFOV
func set_debug(newDebug):
	debugMenu = newDebug
func set_stand_col(newCol):
	standingCollider = newCol
func set_crouch_col(newCol):
	crouchingCollider = newCol
func set_crawl_col(newCol):
	crawlingCollider = newCol
