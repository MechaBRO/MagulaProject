extends CharacterBody3D

const mous_sens = 0.3

var CURRENT_SPEED = 17.0

const walking_spd = 17.0
const sprint_spd = 2.5
const crouch_spd = 10

#signal
signal player_hit
signal Update_ammo
signal Weapon_change
signal Update_Weapon_Stack

var is_crouching = false

const JUMP_VELOCITY = 22.5
const HIT_STAGGER = 8.0

@export var maxHP = 100

@onready var currentHP: int = maxHP

var bullets = load("res://Other/bullet_musket.tscn")
var instance

var can_runbob: bool = false
var can_lowbob: bool = false
var can_headbob: bool = true

var can_run: bool = true

var is_ready: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 50
@onready var head := $Head
@onready var camera := $Head/Main_Cam
@onready var mesh := $O_Mensageiro_game
@onready var raycast := $Head/Main_Cam/RayCast3D
@onready var player := $"."
@onready var view_model_cam = $Head/Main_Cam/SubViewportContainer/SubViewport/view_model_cam
@onready var gun_barrel = $Head/Main_Cam/RayCast3D
@onready var stamina_bar = $"../Player_UI/ProgressBar"

@onready var gunshot = $player_sounds/gunshot

@onready var footstep_audio1 = $player_sounds/mud
@onready var footstep_audio2 = $player_sounds/grass
@onready var footstep_audio3 = $player_sounds/graveldirt

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/Main_Cam/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			head.rotate_y(deg_to_rad(-event.relative.x * mous_sens))
			camera.rotate_x(deg_to_rad(-event.relative.y * mous_sens))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))  
			view_model_cam.sway(Vector2(event.relative.x,event.relative.y))                                       

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("CROUCH"):
		$AnimCrouchCooldown.start()
		if is_crouching == false:
			movementStateChange("crouch")
			CURRENT_SPEED = crouch_spd
		
		elif is_crouching == true:
			movementStateChange("uncrouch")
			CURRENT_SPEED = walking_spd

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$"../Player_UI/ProgressBar".value -= 5
		$Head/Main_Cam/traum_move.cause_trauma()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * CURRENT_SPEED
			velocity.z = direction.z * CURRENT_SPEED
			if Input.is_action_pressed("RUN") and can_run == true:
				stamina_bar.value -= 0.15
				velocity.x *= sprint_spd
				velocity.z *= sprint_spd
				can_headbob = false
				can_runbob = true
		else:
			velocity.x = move_toward(velocity.x, 0, CURRENT_SPEED)
			velocity.z = move_toward(velocity.z, 0, CURRENT_SPEED)
			can_headbob = true
			can_runbob = false
			if stamina_bar.value == 0:
				can_run = false
			elif stamina_bar.value == 100:
				can_run = true

	if input_dir.x>0:
		head.rotation.z = lerp_angle(head.rotation.z,deg_to_rad(-5), 0.03)
	elif input_dir.x<0:
		head.rotation.z = lerp_angle(head.rotation.z,deg_to_rad(5), 0.03)
	else:
		head.rotation.z = lerp_angle(head.rotation.z,deg_to_rad(0), 0.03)
	
	if direction != Vector3() and can_headbob and $AnimCrouchCooldown.is_stopped():
		if is_on_floor():
			$Head/CameraAnim.play("Bobbing")

	if direction != Vector3() and can_lowbob == true and $AnimCrouchCooldown.is_stopped():
		if is_on_floor():
			$Head/CameraAnim.play("Crouch_Bob")

	if direction != Vector3() and can_runbob == true and $AnimCrouchCooldown.is_stopped():
		if is_on_floor():
			$Head/CameraAnim.play("Run_Bob")

	move_and_slide()

#audiofootstep
func _play_footstep_audio():
	footstep_audio2.pitch_scale = randf_range(.8, 1.2)
	footstep_audio2.play()

#shoot
func _input(event):
	if(event.is_action_pressed("FIRE") and is_ready):
		is_ready = false
		$ShootMuskCool.start()
		gunshot.play()
		instance = bullets.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)
		$Head/Main_Cam/trauma_causer.cause_trauma()
	if(event.is_action_pressed("RELOAD")):
		reload()
#func movement_sounds():

func _on_cooldown_timer_timeout():
	is_ready = true

func _on_anim_crouch_cooldown_timeout():
	is_ready = true


func movementStateChange(changeType):
	match changeType:
		"crouch":
			$Head/CameraAnim.play("Standing_Crouch")
			can_runbob = false
			can_run = false
			can_headbob = false
			can_lowbob = true
			is_crouching = true
			changeCollisionShapeTo("crouching")
		"uncrouch":
			$Head/CameraAnim.play_backwards("Standing_Crouch")
			can_runbob = true
			can_run = true
			can_headbob = true
			can_lowbob = false
			is_crouching = false
			changeCollisionShapeTo("standing")

func changeCollisionShapeTo(shape):
	match shape:
		"crouching":
		#Disabled == false is enabled!
			$Crouch.disabled = false
			$Standing.disabled = true
		"standing":
		#Disabled == false is enabled!
			$Standing.disabled = false
			$Crouch.disabled = true

func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER

	#if input_dir.y>0:
		#$Head/CameraAnim.play("Bobbing")
	#elif input_dir.y<0:
		#$Head/CameraAnim.play("Bobbing")
	#else :
		#$Head/CameraAnim.stop()

func reload():
	pass
