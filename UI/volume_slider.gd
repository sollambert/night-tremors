extends HSlider

func _ready():
	value_changed.connect(_on_value_changed)
	pass # Replace with function body.

func _on_value_changed(amount):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), amount)
	if amount == -20:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	pass # Replace with function body.
