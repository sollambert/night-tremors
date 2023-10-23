extends CharacterBody3D

# state
var is_sprinting = false
var sprint_breath_played = false
var flashlight_pressed: bool = false
var flashlight_on : bool = false
var player_moved = false
var weapons = {}
var active_weapon: Weapon
var current_level_id: int

# stats
var sprint = 100
var max_sprint = 100
var health = 50

# signals
signal player_dead

# camlook
var look_sensitivity : float = 10.0

#components
var input_controller : CanvasLayer
var camera : Camera3D
var audio_player_scene = preload("res://Sounds/audio_player.tscn")
var flashlight_scene = preload("res://Weapons/flashlight.tscn")
var flashlight : SpotLight3D
var muzzle : Node3D
var ui : Control
var sprint_recharge_delay_timer : Timer
var sprint_recharge_timer : Timer
var damage_overlay_timer: Timer
var pistol_scene = preload("res://Weapons/Pistol/pistol.tscn")
var shotgun_scene = preload("res://Weapons/Shotgun/shotgun.tscn")
var submachinegun_scene = preload("res://Weapons/SubmachineGun/submachinegun.tscn")
var arms_mount: Node3D

# sounds
var sound_weapon_switch = preload("res://Sounds/SFX/weapswitch.ogg")
var sound_heavy_breathing = preload("res://Sounds/SFX/heavy_breathing.ogg")
var sound_flashlight_on = preload("res://Sounds/SFX/click0.mp3")
var sound_flashlight_off = preload("res://Sounds/SFX/click1.mp3")
var sound_hurt = preload("res://Sounds/SFX/ow.ogg")

# constants
const MIN_LOOK_ANGLE : float = -90.0
const MAX_LOOK_ANGLE : float = 90.0
const MAX_HEALTH = 100
const SPRINT_DRAIN_AMOUNT = 15.0
const SPRINT_RECHARGE_DELAY = 3.0
const SPRINT_RECHARGE_INTERVAL = 0.05
const SPRINT_RECHARGE_AMOUNT = 1.0

# physics constants
@export var speed = 2.0
@export var sprint_speed = 3.0
@export var jump_velocity = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	sprint_recharge_delay_timer = get_node("SprintRechargeDelayTimer")
	sprint_recharge_timer = get_node("SprintRechargeTimer")
	damage_overlay_timer = get_node("DamageOverlayTimer")
	ui = get_node("/root/Main/ViewContainer/UIController/HUD/ui")
	camera = get_node("Camera3D")
	arms_mount = camera.get_node("arms_mount")
	flashlight = flashlight_scene.instantiate()
	camera.add_child(flashlight)
	connect_signals()
	ui.update_sprint_bar(sprint)
	ui.update_health(health)
	
func reset_player():	
	is_sprinting = false
	sprint_breath_played = false
	flashlight_pressed = false
	flashlight_on = true
	player_moved = false
	weapons = {}
	sprint = 100
	max_sprint = 100
	health = 50
	flashlight = flashlight_scene.instantiate()
	ui.update_sprint_bar(sprint)
	ui.update_health(health)
	ui.update_ammo_count(0)
	ui.update_ammo_magazine(0, 10)

func add_ammo(weapon_id, ammo):
	if weapon_id == active_weapon.id:
		active_weapon.update_ammo(active_weapon.ammo + ammo)
	else:
		weapons[weapon_id].ammo += ammo
		if weapons[weapon_id].ammo > weapons[weapon_id].max_ammo:
			weapons[weapon_id].ammo = weapons[weapon_id].max_ammo

func add_weapon(weapon_id, ammo):
	var weapon_object = {
		"ammo": 0,
		"ammo_magazine": 0,
		"max_ammo": 0,
		"max_ammo_magazine": 0
	}
	match weapon_id:
		1:
			weapon_object.max_ammo = 50
			weapon_object.max_ammo_magazine = 10
			pass
		2:
			weapon_object.max_ammo = 24
			weapon_object.max_ammo_magazine = 6
			pass
		3:
			weapon_object.max_ammo = 150
			weapon_object.max_ammo_magazine = 30
			pass
		_:
			pass
	weapon_object.ammo_magazine = ammo
	if weapon_object.ammo_magazine > weapon_object.max_ammo_magazine:
		weapon_object.ammo_magazine = weapon_object.max_ammo_magazine
		weapon_object.ammo = ammo - weapon_object.ammo_magazine
	weapons[weapon_id] = weapon_object
	switch_weapon(weapon_id)
	
func create_weapon(weapon_id):
	var weapon: Weapon
	match weapon_id:
		1:
			weapon = pistol_scene.instantiate()
			pass
		2:
			weapon = shotgun_scene.instantiate()
			pass
		3:
			weapon = submachinegun_scene.instantiate()
			pass
		_:
			pass
	weapon.ui = ui
	weapon.update_ammo(weapons[weapon_id].ammo)
	weapon.update_ammo_magazine(weapons[weapon_id].ammo_magazine)
#	print("weapon after init: " + str(weapon.ammo) + " " + str(weapon.ammo_magazine))
	return weapon

func switch_weapon(weapon_id):
	if weapons.has(weapon_id):
		if active_weapon != null:
			if weapon_id == active_weapon.id:
				return
			play_sound(sound_weapon_switch)
			weapons[active_weapon.id] = {
				"ammo": active_weapon.ammo,
				"ammo_magazine": active_weapon.ammo_magazine,
				"max_ammo": active_weapon.max_ammo,
				"max_ammo_magazine": active_weapon.max_ammo_magazine
			}
			active_weapon.queue_free()
		active_weapon = create_weapon(weapon_id)
		camera.add_child(active_weapon)
		active_weapon.position = arms_mount.position
		flashlight.position = active_weapon.flashlight_mount.position
	pass

func connect_signals():
	input_controller = get_node("/root/Main/InputController")
	input_controller.player_jump.connect(_on_input_controller_player_jump)
	input_controller.player_move.connect(_on_input_controller_player_move)
	input_controller.player_sprint.connect(_on_input_controller_player_sprint)
	input_controller.player_flashlight.connect(_on_input_controller_player_flashlight)
	input_controller.player_mouse_motion.connect(_on_input_controller_player_mouse_motion)
	input_controller.player_weapon_switch.connect(switch_weapon)
	damage_overlay_timer.timeout.connect(_on_damage_overlay_timer_timeout)
	get_node("/root/Main/ViewContainer/UIController").intro_button_pressed.connect(_on_intro_button_pressed)

# fix flashlight stutter
func _on_intro_button_pressed():
	flashlight.visible = flashlight_on
	
func _on_damage_overlay_timer_timeout():
	ui.get_node("damage_overlay").visible = false

func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
	add_child(audio_player)
	audio_player.play_sound(sound)

func add_health(value):
	health += value
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	ui.update_health(health)

func take_damage(damage):
	ui.get_node("damage_overlay").visible = true
	damage_overlay_timer.start(0.25)
	health -= damage
	play_sound(sound_hurt)
	ui.update_health(health)
	if health <= 0:
		die()
	
func die():
	if active_weapon:
		active_weapon.queue_free()
	player_dead.emit()

func _on_sprint_recharge_delay_timer_timeout():
	sprint = 1
	sprint_breath_played = false
	sprint_recharge_delay_timer.stop()
	sprint_recharge_timer.start(SPRINT_RECHARGE_INTERVAL)

func _on_sprint_recharge_timer_timeout():
	sprint += SPRINT_RECHARGE_AMOUNT
	if sprint >= max_sprint:
		sprint = max_sprint
		sprint_recharge_timer.stop()
	ui.update_sprint_bar(sprint)

func _on_input_controller_player_flashlight(pressed):
	if active_weapon:
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

func _on_input_controller_player_mouse_motion(mouse_delta, delta):
	# rotate camera along x axis
	camera.rotation_degrees.x -= mouse_delta.y * look_sensitivity * delta
	# clamp camera x axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, MIN_LOOK_ANGLE, MAX_LOOK_ANGLE)
	# rotate player along y axis
	rotation_degrees.y -= mouse_delta.x * look_sensitivity * delta

func _on_input_controller_player_move(movement_vector, delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var direction = (transform.basis * Vector3(movement_vector.x, 0, movement_vector.y)).normalized()
	if direction:
		player_moved = true
		velocity.x = direction.x * (sprint_speed if is_sprinting else speed) 
		velocity.z = direction.z * (sprint_speed if is_sprinting else speed) 
	else:
		player_moved = false
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func _on_input_controller_player_jump():
	if is_on_floor():
		velocity.y = jump_velocity
	pass # Replace with function body.
