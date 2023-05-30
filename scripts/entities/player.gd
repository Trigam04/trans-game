extends CharacterBody3D

# Enums
enum States { WALKING, SPRINTING, CROUCHING, CRAWLING, AIR, AIR_SPRINTING }
var state = States.WALKING
var prevState = States.WALKING

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
	if (state != prevState): onStateChange(prevState, state)
	
	# Add gravity
	if state == States.AIR or state == States.AIR_SPRINTING:
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_pressed("move_jump") and is_on_floor():
		velocity.y = jumpVel

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
	prevState = state
	
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
			headPivot.rotate_y(-event.relative.x * sensitivity * 0.01)
			cam.rotate_x(-event.relative.y * sensitivity * 0.01)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func calculateState():
	if not is_on_floor() and Input.is_action_pressed("move_sprint"):
		state = States.AIR_SPRINTING
	elif not is_on_floor():
		state = States.AIR
	elif Input.is_action_pressed("move_crawl"):
		state = States.CRAWLING
	elif Input.is_action_pressed("move_crouch"):
		state = States.CROUCHING
	elif Input.is_action_pressed("move_sprint"):
		state = States.SPRINTING
	else:
		state = States.WALKING

func handleState():
	# SPEED / FOV
	match state:
		States.SPRINTING, States.AIR_SPRINTING:
			currentSpeed = sprintSpeed
			Util.tweenVal(cam, "fov", sprintFOV, 0.25)
		States.CROUCHING:
			currentSpeed = crouchSpeed
			Util.tweenVal(cam, "fov", crouchFOV, 0.25)
		States.CRAWLING:
			currentSpeed = crawlSpeed
			Util.tweenVal(cam, "fov", crawlFOV, 0.25)
		States.WALKING, States.AIR:
			currentSpeed = speed
			Util.tweenVal(cam, "fov", fov, 0.25)

func onStateChange(before, now):
	# Oh boy animation hell
	if now == States.CRAWLING and before == States.CROUCHING:
		$AnimationPlayer.play("crouch_to_crawl")
		standingCollider.disabled = true
		crouchingCollider.disabled = true
		crawlingCollider.disabled = false
	elif now == States.CROUCHING and before == States.CRAWLING:
		$AnimationPlayer.play_backwards("crouch_to_crawl")
		standingCollider.disabled = true
		crouchingCollider.disabled = false
		crawlingCollider.disabled = true
	elif now != States.CRAWLING and before == States.CRAWLING:
		$AnimationPlayer.play("reset")
		standingCollider.disabled = false
		crouchingCollider.disabled = true
		crawlingCollider.disabled = true
	elif now == States.CROUCHING and before != States.CRAWLING:
		$AnimationPlayer.play("stand_to_crouch")
		standingCollider.disabled = true
		crouchingCollider.disabled = false
		crawlingCollider.disabled = true
	elif now != States.CROUCHING and before == States.CROUCHING:
		$AnimationPlayer.play_backwards("stand_to_crouch")
		standingCollider.disabled = false
		crouchingCollider.disabled = true
		crawlingCollider.disabled = true


func passDebug():
	debugMenu.set_player_coords(self.get_position())
	debugMenu.set_player_state(Util.get_enum_val_as_string(States, state))
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
