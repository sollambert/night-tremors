extends Node3D

var animation_player : AnimationPlayer
var sound_die = preload("res://Sounds/SFX/action-squelch02.wav")
var audio_player_scene = preload("res://Sounds/audio_player3d.tscn")
var zombie_scene = load("res://Actors/zombie.tscn")
var revive_timer : Timer
var revives
var follow_distance
var scene_controller

const REVIVE_TIME = 15.0

func _ready():
	scene_controller = get_node("/root/Main/SceneController")
	animation_player = get_node("RootNode/Skeleton3D/AnimationPlayer")
	animation_player.play("Dying/mixamo_com")
	play_sound(sound_die)
	if revives != 0:
		revive_timer = get_node("RootNode/ReviveTimer")
		revive_timer.start(REVIVE_TIME)
	
func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
	audio_player.position = global_position
	add_child(audio_player)
	audio_player.play_sound(sound)

func _process(delta):
	if animation_player.is_playing():
		animation_player.advance(delta)

func set_revives(amount):
	revives = amount

func set_follow_distance(distance):
	follow_distance = distance

func undie():
	var skeleton = get_node("RootNode/Skeleton3D")
	var zombie : Node3D = zombie_scene.instantiate()
	zombie.set_revives(revives - 1)
	scene_controller.current_level.add_child(zombie)
	zombie.global_position = skeleton.global_position
	zombie.global_rotation = skeleton.global_rotation
	queue_free()

func _on_revive_timer_timeout():
	undie()
	revive_timer.stop()
	pass # Replace with function body.
