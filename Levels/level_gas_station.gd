extends Node3D

var pumps_active = false
var lights_scene = preload("res://Levels_Utils/gas_station_lights.tscn")
var zombies_scene = preload("res://Levels_Utils/gas_station_zombies.tscn")
var sound_electricity = preload("res://Sounds/SFX/electricity.ogg")
var sound_metal_thunk = preload("res://Sounds/SFX/metal_interaction2.wav")
var lights
var zombies
var audio_player_scene = preload("res://Sounds/audio_player3d.tscn")

var ui_controller
var scene_controller
var input_controller

# Called when the node enters the scene tree for the first time.
func _ready():
	ui_controller = get_node("/root/Main/ViewContainer/UIController")
	ui_controller.display_panel_by_name("Intro_2")
	input_controller = get_node("/root/Main/InputController")
	input_controller.change_control_scheme(input_controller.ControlScheme.INTRO)
	scene_controller = get_node("/root/Main/SceneController")
	pass # Replace with function body.

func _on_area_3d_body_entered(body):
	if body.get_name() == "Player" and !pumps_active:
		pumps_active = true
		lights = lights_scene.instantiate()
		zombies = zombies_scene.instantiate()
		play_sound(sound_metal_thunk)
		play_sound(sound_electricity)
		add_child(lights)
		add_child(zombies)
	pass # Replace with function body.

func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
	add_child(audio_player)
	audio_player.play_sound(sound)

func _on_exit_car_entered():
	if pumps_active:
		scene_controller.start_game_won()
	pass # Replace with function body.
