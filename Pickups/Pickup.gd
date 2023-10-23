class_name Pickup extends Area3D

enum PickupType {
	HEALTH,
	AMMO
}

@export var type: PickupType = PickupType.AMMO
@export var value: int = 10
@export var model_resource = "res://Pickups/health_cross.tscn"

# Components
var model_scene
var model_mount : Node3D

# bobbing
var respawn_timer : Timer
var start_y_pos : float
var bob_height: float = 0.25
var bob_speed : float = 0.5
var bobbing_up : bool = true
var rotate_speed : float = 90.0
@export var respawn : bool = false
@export var respawn_time : float = 10
@export var sound_pickup = preload("res://Sounds/SFX/ammo_pickup.ogg")
var collision_body: CollisionShape3D
var col_layer
var col_mask
var audio_player : AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	model_scene = load(model_resource)
	model_mount = get_node("pickup_mount")
	var model = model_scene.instantiate()
	add_child(model)
	model.position = model_mount.position
	start_y_pos = global_position.y
	respawn_timer = get_node("RespawnTimer")
	collision_body = get_node("CollisionShape3D")
	audio_player = get_node("/root/Main/AudioStreamPlayer")
	col_layer = collision_layer
	col_mask = collision_mask


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y += (bob_speed if bobbing_up == true else -bob_speed) * delta
	global_rotation_degrees.y += rotate_speed * delta
	#if at top, move down
	if bobbing_up and global_position.y > start_y_pos + bob_height:
		bobbing_up = false
	elif !bobbing_up and global_position.y < start_y_pos:
		bobbing_up = true

func _on_body_entered(body):
	if body.name == "Player":
		pickup(body)
		if respawn:
			visible = false
			collision_layer = 0
			collision_mask = 0
			respawn_timer.start(respawn_time)
		else:
			queue_free()
	pass # Replace with function body.
	
func pickup(player):
	audio_player.stream = sound_pickup
	audio_player.play()
	_on_pickup(player)
		
func _on_pickup(_player):
	# Implement in method
	pass	


func _on_respawn_timer_timeout():
	visible = true
	collision_layer = col_layer
	collision_mask = col_mask
	pass # Replace with function body.
