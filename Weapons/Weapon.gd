class_name Weapon extends Node3D

enum WeaponTypes {
	MELEE, SEMI, AUTO 
}

# State
var is_reloading = false

# Stats
@export var max_ammo: int = 50
@export var max_ammo_magazine: int = 10
@export var ammo: int = 0
@export var ammo_magazine: int = 0
@export var damage: int = 10
@export var projectile_speed: float = 30.0
@export var fire_rate: float = 80
@export var reload_time: float = 3.0
@export var weapon_spread: float = 0.01
@export var weapon_type: WeaponTypes = WeaponTypes.SEMI
@export var id: int = 1

# Resources
@export var arms_model_resource: String = "res://Weapons/Pistol/arms.tscn"
@export var weapon_model_resource: String = "res://Weapons/Pistol/pistol_model.tscn"
@export var bullet_model_resource = "res://Weapons/Bullets/9mm_bullet.tscn"
@export var sound_reload_resource = "res://Sounds/SFX/reload_pistol.ogg"
@export var sound_gunshot_resource = "res://Sounds/SFX/pistol.ogg"
@export var ammo_ui_resource = "res://UI/bullet.png"
var sound_out_of_ammo = preload("res://Sounds/SFX/outofammo.ogg")

# Scenes
var audio_player_scene = preload("res://Sounds/audio_player.tscn")
var arms_model_scene
var bullet_model_scene

# Sounds
var sound_reload
var sound_gunshot
var ammo_ui_texture

# Components
var input_controller : CanvasLayer
var arms: Node3D
var bullet_scene = load(bullet_model_resource)
var muzzle: Node3D
var fire_rate_timer: Timer
var reload_timer: Timer
var ui : Control
var flashlight_mount: Node3D
var flashlight
var weapon_model_scene
var player

func _ready():
	# Load resources
	arms_model_scene = load(arms_model_resource)
	bullet_model_scene = load(bullet_model_resource)
	weapon_model_scene = load(weapon_model_resource)
	sound_reload = load(sound_reload_resource)
	sound_gunshot = load(sound_gunshot_resource)
	ammo_ui_texture = load(ammo_ui_resource)

	# Components init
	player = get_node("/root/Main/ViewContainer/SubViewport/Player")
	arms = get_node("arms")
	muzzle = get_node("muzzle")
	flashlight_mount = get_node("flashlight_mount")
	flashlight = player.flashlight
	print(str(flashlight) + " " + str(flashlight_mount) + " " + str(player))
	flashlight.position = flashlight_mount.position

	# UI init
	ui = get_node("/root/Main/ViewContainer/UIController/HUD/ui")
	ui.set_ammo_ui_texture(ammo_ui_texture)
	ui.update_ammo_count(ammo)
	ui.update_ammo_magazine(ammo_magazine, max_ammo_magazine)

	# Init timers
	fire_rate_timer = get_node("/root/Main/ViewContainer/SubViewport/Player/FireRateTimer")
	reload_timer = get_node("/root/Main/ViewContainer/SubViewport/Player/ReloadTimer")

	# Connect signals
	input_controller = get_node("/root/Main/InputController")
	input_controller.player_shoot.connect(_on_input_controller_player_shoot)
	input_controller.player_shoot_held.connect(_on_input_controller_player_shoot_held)
	input_controller.player_reload.connect(_on_input_controller_player_reload)
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	reload_timer.timeout.connect(_on_reload_timer_timeout)

func add_ammo(value):
	ammo += value
	if ammo > max_ammo:
		ammo = max_ammo
	ui.update_ammo_count(ammo)

func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
	add_child(audio_player)
	audio_player.play_sound(sound)

func _on_fire_rate_timer_timeout():
	fire_rate_timer.stop()

func _on_reload_timer_timeout():
	reload_timer.stop()
	is_reloading = false
	var ammo_dif = max_ammo_magazine - ammo_magazine
	if ammo_dif <= ammo:
		update_ammo_magazine(ammo_magazine + ammo_dif)
		update_ammo(ammo - ammo_dif)
	else:
		update_ammo_magazine(ammo_magazine + ammo)
		update_ammo(0)

func _on_input_controller_player_reload():
	if ammo > 0 and !is_reloading and max_ammo_magazine > ammo_magazine:
		is_reloading = true
		play_sound(sound_reload)
		reload_timer.start(reload_time)

func _on_input_controller_player_shoot():
	if weapon_type == WeaponTypes.SEMI:
		if ammo_magazine > 0 and !is_reloading and fire_rate_timer.is_stopped():
			shoot()
	if ammo_magazine == 0:
		play_sound(sound_out_of_ammo)
		
func _on_input_controller_player_shoot_held():
	if weapon_type == WeaponTypes.AUTO:
		if ammo_magazine > 0 and !is_reloading and fire_rate_timer.is_stopped():
			shoot()

func update_ammo(amount):
	ammo = amount
	ui.update_ammo_count(ammo)
	
			
func update_ammo_magazine(amount):
	ammo_magazine = amount
	ui.update_ammo_magazine(ammo_magazine, max_ammo_magazine)
	
func shoot():
	play_sound(sound_gunshot)
	var rng = RandomNumberGenerator.new()
	var x_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
	var y_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
	var z_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
	var bullet : Node3D = bullet_scene.instantiate()
	bullet.damage = damage
	bullet.speed = projectile_speed
	get_node("/root/Main").add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.rotate_x(x_deviation)
	bullet.rotate_y(y_deviation)
	bullet.rotate_z(z_deviation)
	update_ammo_magazine(ammo_magazine - 1)
	muzzle.flash()
	fire_rate_timer.start(60 / fire_rate)
	
