extends Pickup

@export var weapon_id: int = 0

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

func pickup(player):
	audio_player.stream = sound_pickup
	audio_player.play()
	if player.weapons.has(weapon_id):
		player.add_ammo(weapon_id, value)
	else:
		player.add_weapon(weapon_id, value)
