extends CharacterBody3D

# stats
var move_speed : float = 2.25

# attacking
var damage : int = 10
var attack_rate : float = 1.0
var attack_dist : float = 1.5

var health : int = 40
var animation_player: AnimationPlayer
var audio_player_scene = preload("res://Sounds/audio_player3d.tscn")
var zombie_die_scene = load("res://Actors/zombie_die.tscn")
var sound_hit = preload("res://Sounds/SFX/action-objectmove.wav")
var sound_growl = preload("res://Sounds/SFX/growl.ogg")


var revives
var following = false

# components
var player : Node3D
var timer : Timer
var stagger_timer: Timer

var follow_distance: float = 6.0
const max_follow_distance: float = 20.0
const BASE_MOVE_SPEED = 2.25
const STAGGER_TIME = 0.5
const STAGGER_MOVE_SPEED = 0.5

var scene_controller

func _ready():
	scene_controller = get_node("/root/Main/SceneController")
	player = get_node("/root/Main/ViewContainer/SubViewport/Player")
	revives = get_parent_node_3d().revives
	timer = get_node("Timer")
	stagger_timer = get_node("StaggerTimer")
	animation_player = get_node("Skeleton3D/AnimationPlayer")
	animation_player.play("zombie stand up (3)/mixamo_com")
	# setup timer

func _on_timer_timeout():
	if global_position.distance_to(player.global_position) <= attack_dist:
		attack()
	pass # Replace with function body.

func _process(delta):
	if(!animation_player.is_playing()):
		animation_player.play("zombie idle (2)/mixamo_com")
	animation_player.advance(delta)

func attack():
	play_sound(sound_growl)
	animation_player.stop()
	animation_player.play("zombie attack/mixamo_com")
	player.take_damage(damage)
	
func follow_player():
	timer.start(attack_rate)
	following = true
	
func stop_following():
	timer.stop()
	following = false
	
func play_sound(sound):
	var audio_player = audio_player_scene.instantiate()
#	audio_player.position = global_position
	add_child(audio_player)
	audio_player.play_sound(sound)

func _physics_process(_delta):
	var player_distance = global_position.distance_to(player.global_position)
	if player_distance < follow_distance and !following:
		follow_player()
	elif player_distance > max_follow_distance and player_distance > follow_distance:
		stop_following()
	if following:
		# calculate direction to player
		var direction = (player.global_position - global_position).normalized()
		look_at(player.global_position)
		self.rotate_object_local(Vector3(0,1,0), 3.14)
		direction.y = 0
		velocity.x = 0
		velocity.z = 0
		velocity.x += direction.x * move_speed
		velocity.z += direction.z * move_speed
		#move enemy towards player
		if global_position.distance_to(player.global_position) > attack_dist:
			move_and_slide()
		

func take_damage(amount):
	health -= amount
	play_sound(sound_hit)
	play_sound(sound_growl)
	animation_player.stop()
	animation_player.play("zombie reaction hit/mixamo_com")
	move_speed = STAGGER_MOVE_SPEED
	stagger_timer.start(STAGGER_TIME)
	follow_player()
	if health <= 0:
		die()

func die():
	var skeleton = get_node("Skeleton3D")
	var zombie_die : Node3D = zombie_die_scene.instantiate()
	zombie_die.set_revives(revives)
	scene_controller.current_level.add_child(zombie_die)
	zombie_die.global_position = skeleton.global_position
	zombie_die.global_rotation = skeleton.global_rotation
	queue_free()
	
func set_revives(amount):
	revives = amount


func _on_stagger_timer_timeout():
	move_speed = BASE_MOVE_SPEED
	pass # Replace with function body.
