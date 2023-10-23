extends Node3D

signal game_won

var level_city_escape = preload("res://Levels/level_city_escape.tscn")
var level_house = load("res://Levels/level_gas_station.tscn")

var levels = [level_city_escape, level_house]

var current_level: Node3D
var subviewport: SubViewport

var player
var player_scene = preload("res://Player/player.tscn")
var audio_player: AudioStreamPlayer
var ambient_audio_player : AudioStreamPlayer
var sound_starting_car_and_driving = preload("res://Sounds/SFX/starting_car_and_driving.ogg")
var ui_controller

const GAME_CLOSE_DELAY = 8.0

func _ready():
	player = get_node("/root/Main/ViewContainer/SubViewport/Player")
	player.player_dead.connect(_on_player_dead)
	audio_player = get_node("/root/Main/AudioStreamPlayer")
	ambient_audio_player = get_node("/root/Main/AmbientMusic")
	subviewport = get_node("/root/Main/ViewContainer/SubViewport")
	ui_controller = get_node("/root/Main/ViewContainer/UIController")
	load_level(0)
	pass # Replace with function body.

func _on_player_dead():
	player.reset_player()
	load_level(player.current_level_id)
	ui_controller.display_scene_by_name("GameOver")

func load_level(level_id: int):
	if current_level:
		current_level.queue_free()
	current_level = levels[level_id].instantiate()
	subviewport.add_child(current_level)
	var player_start = current_level.get_node("Player_Start")
	player.position = player_start.position
	player.rotation = player_start.rotation
	player.current_level_id = level_id
#
func set_game_paused(paused: bool = true):
	get_tree().paused = paused
	
func start_game_won():
	game_won.emit()
	get_tree().paused = true
	ambient_audio_player.stop_music()
	audio_player.stream = sound_starting_car_and_driving
	audio_player.play()
	
func _on_game_close_timer_timeout():
	get_tree().quit()
