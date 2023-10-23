extends AudioStreamPlayer3D

var has_played = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (!playing):
		if(has_played):
			queue_free()
	pass

func play_sound(sound):
	stream = sound
	play()
	has_played = true

func play_sound_at_location(sound, location: Vector3):
	stream = sound
	position = location
	play()
	has_played = true
