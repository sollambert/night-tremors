extends CharacterBody3D

# state
var is_reloading = false
var is_sprinting = false
var sprint_breath_played = false
var flashlight_pressed: bool = false
var flashlight_on : bool = false
var player_moved = false

# stats
var sprint = 100
var max_sprint = 100
var health = 50

# camlook
var look_sensitivity : float = 10.0

#components
var input_controller : CanvasLayer
var camera : Camera3D
var arms : Node3D
var audio_player_scene = preload("res://Sounds/audio_player.tscn")
var flashlight : SpotLight3D
var flashlight_scene = load("res://Player/flashlight.tscn")
var bullet_scene = load("res://Player/bullet.tscn")
var muzzle : Node3D
var ui : Control
var sprint_recharge_delay_timer : Timer
var sprint_recharge_timer : Timer
var fire_rate_timer: Timer
var reload_timer: Timer

# sounds
var sound_heavy_breathing = preload("res://Sounds/SFX/heavy_breathing.ogg")
var sound_reload_pistol = preload("res://Sounds/SFX/reload_pistol.ogg")
var sound_gunshot = preload("res://Sounds/SFX/gunshot.ogg")
var sound_flashlight_on = preload("res://Sounds/SFX/click0.mp3")
var sound_flashlight_off = preload("res://Sounds/SFX/click1.mp3")
var sound_hurt = preload("res://Sounds/SFX/ow.ogg")

# constants
const MIN_LOOK_ANGLE : float = -90.0
const MAX_LOOK_ANGLE : float = 90.0
const MAX_HEALTH = 100
const MAX_AMMO = 50
const MAX_AMMO_MAGAZINE = 10
const SPRINT_DRAIN_AMOUNT = 15.0
const SPRINT_RECHARGE_DELAY = 3.0
const SPRINT_RECHARGE_INTERVAL = 0.05
const SPRINT_RECHARGE_AMOUNT = 1.0
const FIRE_RATE = 0.8
const RELOAD_TIME = 3.0

# physics constants
@export var SPEED = 2.0
const SPRINT_SPEED = 3.0
@export var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	connect_input_controller()
	camera = get_node("Camera3D")
	flashlight = get_node("Camera3D/Flashlight")
	flashlight.visible = false
	arms = get_node("Camera3D").get_child(0)
	muzzle = arms.get_child(0)
	ui = get_node("/root/Main/HUD Overlay/ui")
	ui.update_sprint_bar(sprint)
	ui.update_health(health)
	ui.update_ammo_count(ammo)
	ui.update_ammo_magazine(ammo_magazine, MAX_AMMO_MAGAZINE)
	sprint_recharge_delay_timer = get_node("SprintRechargeDelayTimer")
	sprint_recharge_timer = get_node("SprintRechargeTimer")
	fire_rate_timer = get_node("FireRateTimer")
	reload_timer = get_node("ReloadTimer")

func connect_input_controller():
	input_controller = get_node("/root/Main/InputController")
	input_controller.player_shoot.connect(_on_input_controller_player_shoot)
	input_controller.player_jump.connect(_on_input_controller_player_jump)
	input_controller.player_reload.connect(_on_input_controller_player_reload)
	input_controller.player_move.connect(_on_input_controller_player_move)
	input_controller.player_sprint.connect(_on_input_controller_player_sprint)
	input_controller.player_flashlight.connect(_on_input_controller_player_flashlight)
	input_controller.player_mouse_motion.connect(_on_input_controller_player_mouse_motion)

func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
	add_child(audio_player)
	audio_player.play_sound(sound)

func add_health(value):
	health += value
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	ui.update_health(health)

func add_ammo(value):
	ammo += value
	if ammo > MAX_AMMO:
		ammo = MAX_AMMO
	ui.update_ammo_count(ammo)

func take_damage(damage):
	health -= damage
	play_sound(sound_hurt)
	ui.update_health(health)
	if health <= 0:
		die()
	
func die():
	get_tree().reload_current_scene()

func _on_sprint_recharge_delay_timer_timeout():
	sprint = 1
	sprint_breath_played = false
	sprint_recharge_delay_timer.stop()
	sprint_recharge_timer.start(SPRINT_RECHARGE_INTERVAL)
	pass # Replace with function body.


func _on_fire_rate_timer_timeout():
	fire_rate_timer.stop()
	pass # Replace with function body.

func _on_sprint_recharge_timer_timeout():
	sprint += SPRINT_RECHARGE_AMOUNT
	if sprint >= max_sprint:
		sprint = max_sprint
		sprint_recharge_timer.stop()
	ui.update_sprint_bar(sprint)
	pass # Replace with function body.


func _on_reload_timer_timeout():
	reload_timer.stop()
	is_reloading = false
	var ammo_dif = MAX_AMMO_MAGAZINE - ammo_magazine
	if ammo_dif <= ammo:
		ammo_magazine += ammo_dif
		ammo -= ammo_dif
	else:
		ammo_magazine += ammo
		ammo = 0
	ui.update_ammo_count(ammo)
	ui.update_ammo_magazine(ammo_magazine, MAX_AMMO_MAGAZINE)
	pass # Replace with function body.


func _on_input_controller_player_flashlight(pressed):
	flashlight_pressed = pressed
	if !flashlight_pressed:
		flashlight_pressed = true
		if flashlight_on:
			play_sound(sound_flashlight_off)
			flashlight.visible = false
			flashlight_on = false
		else:
			play_sound(sound_flashlight_on)
			flashlight.visible = true
			flashlight_on = true
	pass # Replace with function body.


func _on_input_controller_player_reload():
	if ammo > 0 and !is_reloading and MAX_AMMO_MAGAZINE > ammo_magazine:
		is_reloading = true
		play_sound(sound_reload_pistol)
		reload_timer.start(RELOAD_TIME)
	pass # Replace with function body.


func _on_input_controller_player_sprint(delta, started):
	is_sprinting = started and sprint > 0
	if is_sprinting and sprint > 0 and player_moved:
		sprint_recharge_timer.stop()
		sprint -= SPRINT_DRAIN_AMOUNT * delta
	if sprint <= 0 and !sprint_breath_played:
		sprint_breath_played = true
		play_sound(sound_heavy_breathing)
	if sprint_recharge_delay_timer.is_stopped() and !started:
		if  !is_sprinting:
			if sprint <= 0:
				sprint_recharge_delay_timer.start(SPRINT_RECHARGE_DELAY)
			elif sprint < max_sprint and sprint_recharge_timer.is_stopped():
				sprint_recharge_timer.start(SPRINT_RECHARGE_INTERVAL)
	ui.update_sprint_bar(sprint)
	pass # Replace with function body.

func _on_input_controller_player_shoot():
	if ammo_magazine > 0 and !is_reloading and fire_rate_timer.is_stopped():
		play_sound(sound_gunshot)
		var bullet : Node3D = bullet_scene.instantiate()
		get_node("/root/Main").add_child(bullet)
		bullet.global_transform = muzzle.global_transform
		ammo_magazine -= 1
		muzzle.flash()
		fire_rate_timer.start(FIRE_RATE)
		ui.update_ammo_magazine(ammo_magazine, MAX_AMMO_MAGAZINE)

func _on_input_controller_player_mouse_motion(mouse_delta, delta):
	# rotate camera along x axis
	camera.rotation_degrees.x -= mouse_delta.y * look_sensitivity * delta
	# clamp camera x axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, MIN_LOOK_ANGLE, MAX_LOOK_ANGLE)
	# rotate player along y axis
	rotation_degrees.y -= mouse_delta.x * look_sensitivity * delta

func _on_input_controller_player_move(movement_vector, delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction = (transform.basis * Vector3(movement_vector.x, 0, movement_vector.y)).normalized()
	if direction:
		player_moved = true
		velocity.x = direction.x * (SPRINT_SPEED if is_sprinting else SPEED) 
		velocity.z = direction.z * (SPRINT_SPEED if is_sprinting else SPEED) 
	else:
		player_moved = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _on_input_controller_player_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
	pass # Replace with function body.
